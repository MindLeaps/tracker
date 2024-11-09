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
      handle_successful_create_response
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
      success_now title: t(:student_updated), text: t(:student_name_updated, name: @student.proper_name)
      render turbo_stream: [
        turbo_stream.replace(@student, student_turbo_row(@student, @students.find_index(@student), @pagy)),
        turbo_stream.update('flashes', partial: 'shared/flashes')
      ]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def cancel
    skip_authorization
    @group = Group.find params.require :group_id
    @student = Student.find_by(id: params.require(:id))
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

    success_now title: t(:student_deleted), text: t(:student_deleted_text, name: @student.proper_name)
    render turbo_stream: [
      turbo_stream.remove(@student),
      turbo_stream.update('flashes', partial: 'shared/flashes')
    ]
  end

  private

  def handle_successful_create_response
    success_now title: t(:student_added), text: t(:student_name_added, name: @student.proper_name)
    render turbo_stream: [
      turbo_stream.after('turbo-separator', student_turbo_row(@student, 0, @pagy)),
      turbo_stream.replace('new_student', partial: 'form', locals: { student: Student.new, url: group_students_path(@group), is_edit: false, form_class: TableComponents::StudentTurboRow.new_form_class }),
      turbo_stream.update('flashes', partial: 'shared/flashes')
    ]
  end

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
