class StudentGroupsController < HtmlController
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

    @student = Student.new(inline_student_params)
    @student.group = @group

    if @student.save
      success_now(title: t(:student_added), text: t(:student_name_added, name: @student.proper_name))
      render turbo_stream: [
        turbo_stream.prepend('students', @student),
        turbo_stream.replace('form_student', partial: 'form', locals: { student: Student.new, url: group_students_path(@group) })
      ]
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @student = Student.find_by(id: params.require(:id))
    authorize @student

    if @student.update(inline_student_params)
      success(title: t(:student_updated), text: t(:student_name_updated, name: @student.proper_name))
      render turbo_stream: [
        turbo_stream.replace(@student, @student)
      ]
    else
      failure(title: t(:student_invalid), text: t(:fix_form_errors))
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

    success(title: t(:student_deleted), text: t(:student_deleted_text, student: @student.proper_name))
  end

  private

  def inline_student_params
    p = params.require(:student)
    p.permit(*Student.permitted_params)
  end
end
