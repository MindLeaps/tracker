require 'rails_helper'

RSpec.describe Student, type: :model do
  let(:org) { create :organization }

  describe 'validations' do
    subject { create :student, mlid: 'TEST1' }

    describe 'is valid' do
      it 'with first and last name, dob, and gender' do
        student = Student.new mlid: '1S', first_name: 'First', last_name: 'Last', dob: 10.years.ago, gender: 0, organization: org
        expect(student).to be_valid
        expect(student.save).to eq true
      end
    end

    it { should validate_presence_of :mlid }
    it { should validate_presence_of :first_name }
    it { should validate_presence_of :last_name }
    it { should validate_presence_of :dob }
    it { should validate_presence_of :organization }
    it { should validate_uniqueness_of(:mlid).scoped_to :organization_id }
  end

  describe '#proper_name' do
    it 'returns last and first name concatenated' do
      student = Student.new first_name: 'Ignazio', last_name: 'Sorbos'
      expect(student.proper_name).to eq 'Sorbos, Ignazio'
    end
  end

  describe '#grades_for_lesson' do
    before :each do
      @group = create :group
      @student = create :student, group: @group

      @subject = create :subject_with_skills, number_of_skills: 3

      @lesson1 = create :lesson, group: @group, subject: @subject
      @lesson2 = create :lesson, group: @group, subject: @subject

      @gd1 = create :grade_descriptor, skill: @subject.skills[0]
      @gd2 = create :grade_descriptor, skill: @subject.skills[1]

      @grade1 = create :grade, student: @student, lesson: @lesson1, grade_descriptor: @gd1
      @grade2 = create :grade, student: @student, lesson: @lesson1, grade_descriptor: @gd2
      @grade3 = create :grade, student: @student, lesson: @lesson2, grade_descriptor: @gd1
      @grade4 = create :grade, student: @student, lesson: @lesson2, grade_descriptor: @gd2

      @student2 = create :student, group: @group
      @otherstudentgrade1 = create :grade, student: @student2, lesson: @lesson1
      @otherstudentgrade2 = create :grade, student: @student2, lesson: @lesson2
    end

    it 'returns grades that student has in lesson1' do
      expect(@student.grades_for_lesson(@lesson1.id)).to include @grade1, @grade2
    end

    it 'does not return grades that student has in other lessons' do
      expect(@student.grades_for_lesson(@lesson1.id)).to_not include @grade3, @grade4
    end

    it 'does not return grades of other students in any lesson' do
      expect(@student.grades_for_lesson(@lesson1.id)).to_not include @otherstudentgrade1, @otherstudentgrade2
    end

    it 'returns empty skills for ungraded skills in lesson' do
      expect(@student.grades_for_lesson(@lesson1.id).length).to eq 3
    end
  end

  describe '#grade_lesson' do
    before :each do
      @group = create :group
      @student = create :student, group: @group
      @subject = create :subject_with_skills, number_of_skills: 3
      @lesson = create :lesson, group: @group, subject: @subject

      @gd11 = create :grade_descriptor, skill: @subject.skills[0], mark: 1
      @gd12 = create :grade_descriptor, skill: @subject.skills[1], mark: 1
      @gd13 = create :grade_descriptor, skill: @subject.skills[2], mark: 1

      @gd21 = create :grade_descriptor, skill: @subject.skills[0], mark: 2
      @gd22 = create :grade_descriptor, skill: @subject.skills[1], mark: 2
      @gd23 = create :grade_descriptor, skill: @subject.skills[2], mark: 2
    end

    it 'adds student grades' do
      grade1 = build_grade @gd11
      grade2 = build_grade @gd22
      grade3 = build_grade @gd13
      @student.grade_lesson @lesson.id, [grade1, grade2, grade3]

      expect(@student.grades.length).to eq 3
      expect(@student.grades).to include grade1, grade2, grade3
    end

    it 'updates existing grades' do
      create :grade, student: @student, lesson: @lesson, grade_descriptor: @gd11
      grade1 = build_grade @gd21
      grade2 = build_grade @gd22

      @student.grade_lesson @lesson.id, [grade1, grade2]
      expect(@student.grades.length).to eq 2
      expect(@student.grades.map(&:grade_descriptor)).to include @gd21, @gd22
    end

    def build_grade(grade_descriptor)
      Grade.new student: @student, lesson: @lesson, grade_descriptor: grade_descriptor
    end
  end
end
