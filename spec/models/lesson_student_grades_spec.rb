require 'rails_helper'

RSpec.describe LessonStudentGrades, type: :model do
  describe 'validations' do
    it { should validate_presence_of :lesson_id }
    it { should validate_presence_of :student_id }
    it { should validate_presence_of :grade_descriptors }
    it 'validates the existence of a student record' do
      lesson = create :lesson
      model = LessonStudentGrades.new student_id: 1, lesson_id: lesson.id, grade_descriptors: [create(:grade_descriptor)]
      expect(model).to be_invalid
    end
    it 'validates the existence of a lesson record' do
      student = create :student
      model = LessonStudentGrades.new student_id: student.id, lesson_id: 999, grade_descriptors: [create(:grade_descriptor)]
      expect(model).to be_invalid
    end
    it 'validates the validity of grade descriptors' do
      student = create :student
      lesson = create :lesson
      grade_descriptors = [GradeDescriptor.new, GradeDescriptor.new]
      model = LessonStudentGrades.new student_id: student.id, lesson_id: lesson.id, grade_descriptors: grade_descriptors
      expect(model).to be_invalid
    end
  end
end
