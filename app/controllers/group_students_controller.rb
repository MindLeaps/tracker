# rubocop:disable Metrics/ClassLength
class GroupStudentsController < HtmlController
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
    @group = Group.includes(:chapter).find(params.require(:group_id))
    @student = Student.new(inline_student_params)
    @student.group = @group
    @student.organization_id = @group.chapter.organization.id
    authorize @student

    if @student.save
      success_now title: t(:student_added), text: t(:student_name_added, name: @student.proper_name)
    else
      failure_now title: t(:student_invalid), text: t(:fix_form_errors)
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
    else
      failure_now title: t(:student_invalid), text: t(:fix_form_errors)
      render :edit, status: :unprocessable_entity
    end
  end

  def cancel_edit
    @group = Group.find params.require :group_id
    authorize @group, :show?
    @student = Student.find(params.require(:id))
    @pagy, @students = pagy(group_students)
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

  def import
    @group = Group.find params.require :group_id
    authorize @group

    respond_to(&:turbo_stream)
  end

  # rubocop:disable Metrics/MethodLength
  def import_students
    @group = Group.find params.require :group_id
    authorize @group

    file = params[:file]
    if file.present? && file_is_csv(file.content_type)
      students_to_import = CsvDeserializer.new(file).deserialize_students
      if invalid_students_present(students_to_import)
        render template: 'group_students/import', status: :unprocessable_entity, locals: { invalid_students: @invalid_students }
      else
        create_imported_students(students_to_import)
      end
    else
      failure(title: t(:'errors.messages.invalid_file'), text: t(:'errors.messages.csv_mandatory_error'))
      redirect_to group_path(@group)
    end
  end
  # rubocop:enable Metrics/MethodLength

  def invalid_students_present(students)
    @invalid_students = []
    student_mlid = @group.next_student_mlid

    students.each do |student|
      new_student = Student.build(student) do |s|
        s.mlid = student_mlid
        s.group = @group
      end

      @invalid_students << new_student unless new_student.valid?
      student_mlid = @group.next_student_mlid(student_mlid)
    end

    true if @invalid_students.any?
  end

  def create_imported_students(students)
    Student.transaction do
      student_mlid = @group.next_student_mlid
      students.each do |student|
        student[:mlid] = student_mlid
        student[:group] = @group
        Student.create!(student)
        student_mlid = @group.next_student_mlid(student_mlid)
      end
    end

    success(title: t(:imported_students), text: t(:students_imported_successfully))
    redirect_to group_path(@group)
  end

  def group_students
    Student.where(group_id: @group.id).includes(:group).where(deleted_at: nil)
  end

  helper_method :group_students

  private

  def file_is_csv(content_type)
    %w[text/csv text/x-csv application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/csv application/x-csv].include? content_type
  end

  def inline_student_params
    p = params.require(:student)
    p.permit(*Student.permitted_params)
  end
end
# rubocop:enable Metrics/ClassLength
