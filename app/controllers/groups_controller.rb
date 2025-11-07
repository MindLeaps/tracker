class GroupsController < HtmlController
  include Pagy::Method

  has_scope :exclude_deleted, type: :boolean, default: true
  has_scope :table_order, type: :hash, default: { key: :created_at, order: :desc }
  has_scope :search, only: [:show, :index]

  def index
    authorize Group
    @group = Group.new
    @pagy, @groups = pagy policy_scope(apply_scopes(GroupSummary.includes(chapter: [:organization])), policy_scope_class: GroupPolicy::Scope)
  end

  def show
    @group = Group.includes(:chapter).find params[:id]
    authorize @group
    @unenrolled_students = Student.unenrolled_for_organization(@group.chapter.organization_id)
    @students_with_prior_grades = @group.students_with_grades_before_enrollment
    @group_summaries = GroupLessonSummary.where(group_id: @group.id).where.not(average_mark: nil).order(lesson_date: :asc).last(30).map do |summary|
      {
        lesson_date: summary.lesson_date,
        average_mark: summary.average_mark
      }
    end
  end

  def new
    authorize Group
    @group = populate_new_group
    respond_to do |format|
      format.turbo_stream
      format.html { render :new }
    end
  end

  def edit
    @group = Group.find params.require :id
    authorize @group
  end

  def create
    @group = Group.new group_params
    if @group.valid? && @group.save
      authorize @group
      success(title: t(:group_added), text: t(:group_with_name_added, group: @group.group_name))
      return redirect_to groups_path
    end
    skip_authorization
    handle_turbo_failure_responses({ title: t(:group_invalid), text: t(:fix_form_errors) })
  end

  def update
    @group = Group.find params.require :id
    if @group.valid? && @group.update(group_params)
      authorize @group
      success title: t(:group_updated), text: t(:group_name_updated, group: @group.group_name)
      return redirect_to(flash[:redirect] || group_path(@group))
    end
    skip_authorization

    failure title: t(:group_invalid), text: t(:fix_form_errors)
    render :edit, status: :unprocessable_entity
  end

  def destroy
    @group = Group.find params.require :id
    authorize @group
    return unless @group.delete_group_and_dependents

    success(title: t(:group_deleted), text: t(:group_deleted_text, group: @group.group_name), button_path: undelete_group_path, button_method: :post, button_text: t(:undo))
    redirect_to request.referer || @group.path
  end

  def undelete
    @group = Group.find params.require :id
    authorize @group
    return unless @group.restore_group_and_dependents

    success(title: t(:group_restored), text: t(:group_restored_text, group: @group.group_name))
    redirect_to group_path
  end

  def enroll_students
    @group = Group.find params.require :id
    authorize @group

    @unenrolled_students = Student.unenrolled_for_organization(@group.chapter.organization_id)
    respond_to(&:turbo_stream)
  end

  def confirm_enrollments
    @group = Group.find params.require :id
    authorize @group
    @students = params.require(:students)

    count = 0
    @students.filter { |s| s[:to_enroll] }&.each do |s|
      student = Student.find s[:id]
      student.enrollments << Enrollment.new(student: @student, group: @group, active_since: s[:enrollment_start_date])
      student.save
      count += 1
    end

    success(title: t(:students_enrolled), text: t(:students_enrolled_in_group_text, count: count, group: @group.group_name))
    redirect_to group_path(@group)
  end

  private

  def group_params
    params.require(:group).permit :group_name, :mlid, :chapter_id
  end

  def populate_new_group
    group = Group.new
    group.chapter = Chapter.find(new_params[:chapter_id]) if new_params[:chapter_id]
    group
  end

  def new_params
    params.permit :chapter_id
  end
end
