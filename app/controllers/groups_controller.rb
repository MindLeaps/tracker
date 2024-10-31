class GroupsController < HtmlController
  include Pagy::Backend
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
    @students = Student.where(group_id: @group.id).where(deleted_at: nil).order(last_name: :asc)
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

  def new_student
    @group = Group.find params.require :id
    authorize @group

    @student = Student.new(group: @group)
  end

  def create_new_student
    @group = Group.find params.require :id
    authorize @group
    @student = Student.new(inline_student_params)
    @student.group = @group

    if @student.save
      success_now(title: t(:student_added), text: t(:student_name_added, name: @student.proper_name))
      render turbo_stream: [
        turbo_stream.prepend('students', @student),
        turbo_stream.replace('form_student', partial: 'form', locals: { student: Student.new, url: create_new_student_group_path })
      ]
    else
      render :new_student, status: :unprocessable_entity
    end
  end

  def delete_student
    @student = Student.find_by(id: params.require(:id))
    authorize @student

    @student.deleted_at = Time.zone.now
    return unless @student.save

    render turbo_stream: [turbo_stream.remove(@student)]
    success_now(title: t(:student_deleted), text: t(:student_deleted_text, student: @student.proper_name))
  end

  def edit_student
    @student = Student.find_by(id: params.require(:id))
    authorize @student
  end

  def update_student
    @student = Student.find_by(id: params.require(:id))
    authorize @student

    if @student.update(inline_student_params)
      success_now(title: t(:student_updated), text: t(:student_name_updated, name: @student.proper_name))
      render turbo_stream: [
        turbo_stream.replace(@student, @student)
      ]
    else
      failure_now(title: t(:student_invalid), text: t(:fix_form_errors))
      render :edit_student, status: :unprocessable_entity
    end
  end

  private

  def inline_student_params
    p = params.require(:student)
    p.permit(*Student.permitted_params)
  end

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
