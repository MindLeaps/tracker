class StudentGroupsController < HtmlController
  include Pagy::Backend
  skip_after_action :verify_policy_scoped

  def new
    @group = Group.find params.require :group_id
    authorize @group

    @student = Student.new(group: @group)
  end

  def edit
    @group = Group.find params.require :group_id

    @student = Student.find_by(id: params.require(:id))
    authorize @student
  end

  def create
    @group = Group.find params.require :group_id
    authorize @group
    @pagy, @students = pagy Student.where(group_id: @group.id).where(deleted_at: nil).includes(:group)
    @student = Student.new(inline_student_params)
    @student.group = @group

    if @student.save
      render turbo_stream: [
        turbo_stream.prepend('students', @student),
        turbo_stream.replace('form_student', partial: 'form', locals: { student: Student.new, url: group_students_path(@group) })
      ]
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @group = Group.find params.require :group_id
    @student = Student.find_by(id: params.require(:id))
    @pagy, @students = pagy Student.where(group_id: @group.id).where(deleted_at: nil).includes(:group)
    authorize @student

    if @student.update(inline_student_params)
      render turbo_stream: [
        turbo_stream.replace(@student, @student)
      ]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @student = Student.find_by(id: params.require(:id))
    authorize @student

    @student.deleted_at = Time.zone.now
    return unless @student.save

    render turbo_stream: [
      turbo_stream.remove(@student)
    ]
  end

  private

  def inline_student_params
    p = params.require(:student)
    p.permit(*Student.permitted_params)
  end
end
