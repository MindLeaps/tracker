class LessonStudentGrades
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :lesson_id, :student_id, :grade_descriptors

  validates :lesson_id, :student_id, :grade_descriptors, presence: true
  validate :student_record_must_exist, :lesson_record_must_exist, :validate_grade_descriptors

  def student_record_must_exist
    return if Student.exists? id: student_id

    errors.add :student_id, "Student with ID #{student_id} does not exist."
  end

  def lesson_record_must_exist
    return if Lesson.exists? id: lesson_id

    errors.add :lesson_id, "Lesson with ID #{lesson_id} does not exist."
  end

  def validate_grade_descriptors
    return if grade_descriptors.nil?
    grade_descriptors.each { |g| errors.add :grade_descriptors, 'Grade Descriptor invalid.' if g.invalid? }
  end
end
