class StudentLessonsController < HtmlController
  skip_after_action :verify_policy_scoped

  def show
    lesson = Lesson.find params[:lesson_id]
    authorize lesson, :show?
    @student_lesson = StudentLesson.new(student_id: params.require(:id), lesson:)
    @absent = lesson.absences.map(&:student_id).include? @student_lesson.student_id
    respond_to(&:turbo_stream)
  end

  def update
    lesson = Lesson.find params.require(:lesson_id)
    authorize lesson, :create?

    student_lesson = StudentLesson.new(student_id: params.require(:id), lesson:)
    formatted_grade_attributes = format_attributes
    student_lesson.perform_grading(formatted_grade_attributes, student_absent?)

    success(title: t(:student_graded), text: t(:student_graded_text, student: student_lesson.student.proper_name))
    redirect_to lesson_path(lesson)
  end

  private

  def student_absent?
    absence_param = params.require(:student_lesson).permit(:absence)[:absence]
    ActiveRecord::Type::Boolean.new.cast(absence_param) || false
  end

  def grades_attributes
    params.require(:student_lesson).permit(grades_attributes: %i[skill_id grade_descriptor_id])[:grades_attributes]&.values
  end

  def format_attributes
    retrieved_attributes = grades_attributes

    if retrieved_attributes.present?
      retrieved_attributes
        .select { |g| g['grade_descriptor_id'].present? or g['grade_descriptor_id'].empty? }
        .reduce({}) { |acc, v| acc.merge(v['skill_id'].to_i => Integer(v['grade_descriptor_id'], exception: false)) }
    end
  end
end
