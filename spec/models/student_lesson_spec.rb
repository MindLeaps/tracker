# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StudentLesson, type: :model do
  describe 'relations' do
    it { should belong_to :student }
    it { should belong_to :subject }
    it { should have_many :skills }

    it 'has correct associations' do
      @subject = create :subject_with_skills, number_of_skills: 3
      @student = create :student
      @lesson = create :lesson, group: @student.group, subject: @subject

      student_lesson = StudentLesson.find_by(student: @student, lesson: @lesson)
      expect(student_lesson.subject).to eq @subject
      expect(student_lesson.skills).to match_array @subject.skills
    end
  end

  describe '#grades' do
    before :each do
      @student = create :graded_student, grades: {
        'Memorization' => [3],
        'Grit' => [2],
        'Discipline' => []
      }
      @other_student = create :graded_student, grades: {
        'Discipline' => [3,4,2],
        'Grit' => [1,2,3],
        'Language' => [1,2]
      }
      @student_lesson = StudentLesson.find_by student: @student
    end

    it 'returns saved grades' do
      saved_grades = Grade.where(student: @student).all
      expect(@student_lesson.grades).to include(*saved_grades)
    end

    it 'returns nulled grades for missing grades' do
      expect(@student_lesson.grades.length).to eq 3
      expect(@student_lesson.grades.map(&:mark)).to include 3, 2, nil
    end
  end
end
