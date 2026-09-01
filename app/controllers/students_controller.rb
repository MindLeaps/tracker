# rubocop:disable-next Metrics/ClassLength
class StudentsController < HtmlController
  include Pagy::Method
  include CollectionHelper

  has_scope :exclude_deleted, only: :index, type: :boolean, default: true
  has_scope :table_order, only: [:index], type: :hash, default: { key: :created_at, order: :desc }
  has_scope :student_lesson_order, only: [:show], type: :hash, default: { key: :date, order: :desc } do |_controller, scope, value|
    scope.table_order value
  end
  has_scope :search, only: :index

  # rubocop:disable-next Metrics/AbcSize
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

  def show
    @student = Student.includes(:profile_image, :organization).find params.require(:id)
    authorize @student
    lesson_details = apply_scopes(StudentLessonDetail.where(student_id: @student.id)).to_a
    @student_lessons_details_by_subject = lesson_details.group_by(&:subject_id)
    @subjects = policy_scope(Subject).includes(:skills).where(id: @student_lessons_details_by_subject.keys)
    graded_lessons = graded_lesson_details(lesson_details)
    @lesson_summaries = graded_lessons.last(30).map { |lesson| lesson_summary(lesson) }
    @nr_of_lessons_present = graded_lessons.size
    populate_skill_averages
    populate_skill_growth(graded_lessons)
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

  private

  def lesson_summary(detail)
    { lesson_date: detail.date, average_mark: detail.average_mark, lesson_url: lesson_path(detail.lesson_id) }
  end

  def graded_lesson_details(lesson_details)
    lesson_details.reject { |lesson| lesson.average_mark.nil? }.sort_by(&:date)
  end

  def populate_skill_averages
    student_averages = StudentAverage.where(student_id: @student.id).to_a

    @skill_averages = student_averages
                      .group_by(&:subject_name)
                      .transform_values do |averages|
                        averages.map do |average|
                          { skill: average.skill_name, average: average.average_mark }
                        end
                      end

    scores = student_averages.map(&:average_mark)
    @total_average_score = average_from_array(scores) if scores.any?
  end

  def populate_skill_growth(graded_lessons)
    skills_with_enough_grades = marks_by_skill_id(graded_lessons).values.select { |skill| skill[:marks].size >= 2 }
    growths = skills_with_enough_grades.map { |skill| { skill_name: skill[:name], growth: skill[:marks].last - skill[:marks].first } }

    @most_improved_skill = growths.max_by { |g| g[:growth] }
    @least_improved_skill = growths.min_by { |g| g[:growth] }
  end

  def marks_by_skill_id(graded_lessons)
    marks = Hash.new { |hash, key| hash[key] = { name: nil, marks: [] } }
    graded_lessons.each do |detail|
      detail.skill_marks.each do |skill_id, mark_info|
        skill = marks[skill_id]
        skill[:name] = mark_info['skill_name']
        skill[:marks] << mark_info['mark']
      end
    end
    marks
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
