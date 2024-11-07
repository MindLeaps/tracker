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
    @student = Student.new(inline_student_params)
    @student.group = @group
    @pagy, @students = pagy(group_students)

    if @student.save
      render turbo_stream: [
        turbo_stream.after('turbo-separator', student_turbo_row(@student, 0, @pagy)),
        turbo_stream.replace('new_student', partial: 'form', locals: { student: Student.new, url: group_students_path(@group), is_edit: false, form_class: TableComponents::StudentTurboRow.new_form_class }),
      ]
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @group = Group.find params.require :group_id
    @student = Student.find_by(id: params.require(:id))
    authorize @student
    @pagy, @students = pagy(group_students)

    if @student.update(inline_student_params)
      render turbo_stream: [
        turbo_stream.replace(@student, student_turbo_row(@student, @students.find_index(@student), @pagy))
      ]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def cancel
    @group = Group.find params.require :group_id
    @student = Student.find_by(id: params.require(:id))
    authorize @student
    @pagy, @students = pagy(group_students)

    render turbo_stream: [
      turbo_stream.replace(@student, student_turbo_row(@student, @students.find_index(@student), @pagy))
    ]
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

  def student_turbo_row(student, counter, pagy)
    TableComponents::StudentTurboRow.new(item: student, item_counter: counter, pagy: pagy)
  end

  def group_students
    Student.where(group_id: @group.id).where(deleted_at: nil)
  end

  def inline_student_params
    p = params.require(:student)
    p.permit(*Student.permitted_params)
  end
end
