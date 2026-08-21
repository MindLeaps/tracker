# rubocop:disable Metrics/ClassLength
class StudentsController < HtmlController
  include Pagy::Method
  include CollectionHelper

  has_scope :exclude_deleted, only: [:index, :bulk_tag_assignment], type: :boolean, default: true
  has_scope :table_order, only: [:index], type: :hash, default: { key: :created_at, order: :desc }
  has_scope :student_lesson_order, only: [:show], type: :hash, default: { key: :date, order: :desc } do |_controller, scope, value|
    scope.table_order value
  end
  has_scope :search, only: [:index, :bulk_tag_assignment]

  # rubocop:disable Metrics/AbcSize
  def index
    authorize Student
    respond_to do |format|
      format.html do
        @pagy, @student_rows = pagy apply_scopes(policy_scope(Student.includes(:tags, :organization)))
      end

      format.csv do
        @group = Group.find(params.require(:group_id))
        @students = apply_scopes(policy_scope(@group.students.where(deleted_at: nil)))
        filename = ["#{@group.group_name} - Enrolled Students", Time.zone.today.to_s].join(' ')
        send_data csv_from_array_of_hashes(@students.map { |s| s.to_export(@group.id) }), filename:, content_type: 'text/csv'
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  def show
    @student = Student.includes(:profile_image, :organization).find params.require(:id)
    authorize @student
    @student_lessons_details_by_subject = apply_scopes(StudentLessonDetail.where(student_id: @student.id)).all.group_by(&:subject_id)
    @subjects = policy_scope(Subject).includes(:skills).where(id: @student_lessons_details_by_subject.keys)
    @lesson_summaries = StudentLessonSummary.where(student_id: @student.id).where.not(average_mark: nil).order(lesson_date: :asc).last(30).map { |s| lesson_summary(s) }
    @skill_averages = {}
    populate_skill_averages
  end

  def populate_skill_averages
    StudentAverage.where(student_id: @student.id).load.each do |average|
      @skill_averages[average[:subject_name].to_s] = [] unless @skill_averages[average[:subject_name].to_s]
      @skill_averages[average[:subject_name].to_s].push({ skill: average[:skill_name], average: average[:average_mark] })
    end
  end

  def new
    authorize Student
    @student = populate_new_student
    flash_redirect request.referer
  end

  def mlid
    authorize Student, :new?
    organization = Organization.find params.require(:organization_id)
    student = params[:student_id].present? ? Student.find(params.require(:student_id)) : nil
    mlid = MindleapsIdService.generate_student_mlid organization.id
    show_label = params.key? :show_label
    mlid_component = ::CommonComponents::StudentMlidInput.new(mlid, student_id: student&.id || nil, show_label:)
    render turbo_stream: [
      turbo_stream.replace(student.present? ? "#{CommonComponents::StudentMlidInput::ELEMENT_ID}_#{student.id}" : CommonComponents::StudentMlidInput::ELEMENT_ID, mlid_component)
    ]
  end

  def edit
    @student = Student.find params[:id]
    authorize @student
    @student.student_images.build
  end

  def create
    @student = Student.new student_params
    authorize @student
    if params[:add_group]
      @student.enrollments.build
      render :new, status: :ok
    elsif @student.save
      success(title: :student_added, text: t(:student_name_added, name: @student.proper_name), link_text: t(:create_another), link_path: new_student_path)
      redirect_to(flash[:redirect] || student_path(@student))
    else
      failure_now(title: t(:student_invalid), text: t(:fix_form_errors))
      render :new, status: :unprocessable_content
    end
  end

  def update
    @student = Student.find params[:id]
    authorize @student
    @student.assign_attributes student_params

    if params[:add_group]
      @student.enrollments.build
      render :new, status: :ok
    elsif @student.save
      success title: t(:student_updated), text: t(:student_name_updated, name: @student.proper_name)
      redirect_to(flash[:redirect] || student_path(@student))
    else
      failure title: t(:student_invalid), text: t(:fix_form_errors)
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @student = Student.find params.require :id
    authorize @student
    @student.deleted_at = Time.zone.now

    return unless @student.save

    success(title: t(:student_deleted), text: t(:student_deleted_text, student: @student.proper_name), button_path: undelete_student_path, button_method: :post, button_text: t(:undo))
    redirect_to student_path
  end

  def undelete
    @student = Student.find params.require :id
    authorize @student
    @student.deleted_at = nil

    return unless @student.save

    success title: t(:student_restored), text: t(:student_restored_text, name: @student.proper_name)
    redirect_to student_path
  end

  def bulk_tag_assignment
    authorize Student, :new?
    @pagy, students = pagy apply_scopes(policy_scope(Student.includes(:tags)))
    @students = students.to_a
    @tags = TagPolicy::Scope.new(current_user, Tag).resolve.order(:tag_name)
  end

  def confirm_bulk_tag_assignment
    authorize Student, :new?
    tags = TagPolicy::Scope.new(current_user, Tag).resolve.where(id: Array(params[:tag_ids]).compact_blank).to_a

    if tags.empty?
      failure title: t(:no_tags_selected), text: t(:select_at_least_one_tag)
      return redirect_to students_path
    end

    student_count = perform_bulk_tag_assignment(tags)

    success title: t(:tags_assigned), text: t(:tags_assigned_text, count: student_count, tags: tags.map(&:tag_name).join(', '))
    redirect_to students_path
  end

  private

  def perform_bulk_tag_assignment(tags)
    student_ids = policy_scope(Student).where(id: selected_student_ids).pluck(:id)
    assign_tags_to_students(student_ids, tags.map(&:id))
    student_ids.size
  end

  def selected_student_ids
    params.require(:students).filter_map { |s| s[:id] if s[:to_tag] }
  end

  # Bulk-inserts the missing (student, tag) pairs in a single query instead of issuing a
  # find_or_create_by per student per tag, which would otherwise be O(students * tags) queries.
  def assign_tags_to_students(student_ids, tag_ids)
    return if student_ids.empty? || tag_ids.empty?

    ActiveRecord::Base.transaction do
      rows = missing_student_tag_rows(student_ids, tag_ids)
      next if rows.empty?

      # rubocop:disable Rails/SkipsModelValidations
      StudentTag.insert_all(rows)
      # rubocop:enable Rails/SkipsModelValidations
    end
  end

  def missing_student_tag_rows(student_ids, tag_ids)
    existing_pairs = StudentTag.where(student_id: student_ids, tag_id: tag_ids).pluck(:student_id, :tag_id).to_set
    now = Time.current

    student_ids.flat_map do |student_id|
      tag_ids.filter_map do |tag_id|
        next if existing_pairs.include?([student_id, tag_id])

        { student_id: student_id, tag_id: tag_id, created_at: now, updated_at: now }
      end
    end
  end

  def lesson_summary(summary)
    { lesson_date: summary.lesson_date, average_mark: summary.average_mark, lesson_url: lesson_path(summary.lesson_id) }
  end

  def student_params
    p = params.require(:student)
    p.permit(*Student.permitted_params)
  end

  def set_back_url_flash
    flash[:back_from_student] = flash[:back_from_student] || request.referer
  end

  def populate_new_student
    student = Student.new
    if new_params[:group_id]
      group = Group.includes(:chapter).find new_params[:group_id]
      if group
        student.enrollments.build(group: group)
        student.organization_id = group.chapter.organization_id
      end
    end
    student
  end

  def new_params
    params.permit :group_id
  end
end
# rubocop:enable Metrics/ClassLength
