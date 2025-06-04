class GroupStudentsController < HtmlController
  include Pagy::Backend
  skip_after_action :verify_policy_scoped

  def new
    @group = Group.find params.require :group_id
    authorize @group

    @student = Student.new(group: @group)
  end

  def edit
    @student = Student.find_by(id: params.require(:id))
    @group = Group.find_by(id: params.require(:group_id))

    authorize @student
  end

  # rubocop:disable Metrics/AbcSize
  def create
    @group = Group.includes(:chapter).find(params.require(:group_id))
    @student = Student.new(inline_student_params)
    @student.organization_id = @group.chapter.organization.id
    @student.current_group_id = @group.id
    authorize @student
    @new_student_enrollment = Enrollment.new(group: @group, student: @student, active_since: Time.zone.now)

    if @student.save && @new_student_enrollment.save
      success_now title: t(:student_added), text: t(:student_name_added, name: @student.proper_name)
    else
      failure_now title: t(:student_invalid), text: t(:fix_form_errors)
      render :new, status: :unprocessable_entity
    end
  end
  # rubocop:enable Metrics/AbcSize

  def update
    @student = Student.find_by(id: params.require(:id))
    @group = Group.find_by(id: params.require(:group_id))
    authorize @student
    @pagy, @students = pagy(group_students)
    @student.current_group_id = @group.id

    if @student.update(inline_student_params)
      success_now title: t(:student_updated), text: t(:student_name_updated, name: @student.proper_name)
    else
      failure_now title: t(:student_invalid), text: t(:fix_form_errors)
      render :edit, status: :unprocessable_entity
    end
  end

  def cancel_edit
    @group = Group.find_by(id: params.require(:group_id))
    authorize @group, :show?
    @student = Student.find_by(id: params.require(:id))
    @student.current_group_id = @group.id

    @pagy, @students = pagy(@group.students)
    @students.each do |s|
      s.current_group_id = @group.id
    end
  end

  def destroy
    @student = Student.find_by(id: params.require(:id))
    authorize @student

    @student.deleted_at = Time.zone.now
    return unless @student.save

    success_now title: t(:student_deleted), text: t(:student_deleted_text, student: @student.proper_name)
    render turbo_stream: [
      turbo_stream.remove(@student),
      turbo_stream.update('flashes', partial: 'shared/flashes')
    ]
  end

  def group_students
    @group.students.where(deleted_at: nil)
  end

  helper_method :group_students

  private

  def inline_student_params
    p = params.require(:student)
    p.permit(*Student.permitted_params)
  end
end
