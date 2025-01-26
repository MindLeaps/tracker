class StudentsController < HtmlController
  include Pagy::Backend
  has_scope :exclude_deleted, only: :index, type: :boolean, default: true
  has_scope :exclude_empty, only: :performance, type: :boolean, default: true
  has_scope :table_order, only: [:index], type: :hash, default: { key: :created_at, order: :desc }
  has_scope :student_lesson_order, only: [:show], type: :hash, default: { key: :date, order: :desc } do |_controller, scope, value|
    scope.table_order value
  end
  has_scope :search, only: :index

  def index
    authorize Student
    @pagy, @student_rows = pagy apply_scopes(policy_scope(Student.includes(:tags, :organization)))
  end

  def show
    @student = Student.includes(:profile_image, :organization).find params.require(:id)
    authorize @student
    @student_lessons_details_by_subject = apply_scopes(StudentLessonDetail.where(student_id: params[:id])).all.group_by(&:subject_id)
    @subjects = policy_scope(Subject).includes(:skills).where(id: @student_lessons_details_by_subject.keys)
    @lesson_summaries = StudentLessonSummary.where(student_id: @student.id).where.not(average_mark: nil).order(lesson_date: :asc).last(30).map do |summary|
      {
        lesson_date: summary.lesson_date,
        average_mark: summary.average_mark
      }
    end
  end

  def new
    authorize Student
    @student = populate_new_student
    flash_redirect request.referer
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
      render :new, status: :unprocessable_entity
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
      render :edit, status: :unprocessable_entity
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
