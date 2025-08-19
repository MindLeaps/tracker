# rubocop:disable Metrics/ClassLength
class StudentsController < HtmlController
  include Pagy::Backend
  include CollectionHelper

  has_scope :exclude_deleted, only: :index, type: :boolean, default: true
  has_scope :exclude_empty, only: :performance, type: :boolean, default: true
  has_scope :table_order, only: [:index], type: :hash, default: { key: :created_at, order: :desc }
  has_scope :student_lesson_order, only: [:show], type: :hash, default: { key: :date, order: :desc } do |_controller, scope, value|
    scope.table_order value
  end
  has_scope :search, only: :index
  has_scope :by_group, as: :group_id

  def index
    authorize Student
    respond_to do |format|
      format.html do
        @pagy, @student_rows = pagy apply_scopes(policy_scope(StudentTableRow.includes(:tags, :organization)))
      end

      format.csv do
        @students = apply_scopes(policy_scope(Student)).includes(:group).all
        filename = ["#{@students.first.group.group_name} - Students", Time.zone.today.to_s].join(' ')
        send_data csv_from_array_of_hashes(@students.map(&:to_export)), filename:, content_type: 'text/csv'
      end
    end
  end

  def show
    @student = Student.includes(:profile_image, group: { chapter: [:organization] }).find params.require(:id)
    authorize @student
    @student_lessons_details_by_subject = apply_scopes(StudentLessonDetail.where(student_id: params[:id])).all.group_by(&:subject_id)
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
    group = Group.includes(:chapter).find params.require(:group_id)
    organization_id = group.chapter.organization_id
    mlid = MindleapsIdService.generate_student_mlid organization_id
    show_label = params.key? :show_label
    mlid_component = ::CommonComponents::StudentMlidInput.new(mlid, show_label:)
    render turbo_stream: [
      turbo_stream.replace(CommonComponents::StudentMlidInput::ELEMENT_ID, mlid_component)
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
    if @student.save
      success(title: :student_added, text: t(:student_name_added, name: @student.proper_name), link_text: t(:create_another), link_path: new_student_path(group_id: @student.group_id))
      return redirect_to(flash[:redirect] || student_path(@student))
    end
    failure_now(title: t(:student_invalid), text: t(:fix_form_errors))
    render :new, status: :unprocessable_entity
  end

  def update
    @student = Student.find params[:id]
    authorize @student
    if update_student @student
      success title: t(:student_updated), text: t(:student_name_updated, name: @student.proper_name)
      return redirect_to(flash[:redirect] || student_path(@student))
    end

    failure title: t(:student_invalid), text: t(:fix_form_errors)
    render :edit, status: :unprocessable_entity
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

  private

  def lesson_summary(summary)
    { lesson_date: summary.lesson_date, average_mark: summary.average_mark }
  end

  def student_params
    p = params.require(:student)
    p[:student_tags_attributes] = p.fetch(:tag_ids, []).map { |tag_id| { tag_id: } }
    p.delete :tag_ids
    p[:organization_id] = Group.find(p[:group_id]).chapter[:organization_id] if p[:organization_id].blank? && p[:group_id].present?
    p.permit(*Student.permitted_params)
  end

  def set_back_url_flash
    flash[:back_from_student] = flash[:back_from_student] || request.referer
  end

  def populate_new_student
    student = Student.new
    student.group = Group.find(new_params[:group_id]) if new_params[:group_id]
    student
  end

  def new_params
    params.permit :group_id
  end

  def update_student(student)
    p = student_params
    tag_ids = p[:student_tags_attributes].pluck(:tag_id)
    tags = Tag.where id: tag_ids
    p.delete :student_tags_attributes
    student.tags = tags
    student.update p
  end
end
# rubocop:enable Metrics/ClassLength
