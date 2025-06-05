# == Schema Information
#
# Table name: student_lessons
#
#  lesson_id  :uuid
#  student_id :integer
#
require 'rails_helper'

RSpec.describe StudentLesson, type: :model do
  describe 'relations' do
    it { should belong_to :student }
    it { should have_one :subject }
    it { should have_many :skills }

    it 'has correct associations' do
      @subject = create :subject_with_skills, number_of_skills: 3
      @group = create :group, chapter: create(:chapter, organization: @subject.organization)
      @student = create :enrolled_student, organization: @group.chapter.organization, groups: [@group]
      @lesson = create :lesson, group: @student.enrollments.first.group, subject: @subject

      student_lesson = StudentLesson.find_by(student: @student, lesson: @lesson)
      expect(student_lesson.subject).to eq @subject
      expect(student_lesson.skills).to match_array @subject.skills
    end
  end

  describe '#formatted_grades_for_grading' do
    before :each do
      @student = create :graded_student, grades: {
        'Memorization' => [3],
        'Grit' => [2],
        'Discipline' => []
      }
      @other_student = create :graded_student, grades: {
        'Grit' => [1, 2, 3],
        'Language' => [1, 2]
      }
      @student_lesson = StudentLesson.find_by student: @student
    end

    it 'returns saved grades' do
      saved_grades = Grade.where(student: @student).all
      expect(@student_lesson.formatted_grades_for_grading).to include(*saved_grades)
    end

    it 'returns nulled grades for missing grades' do
      expect(@student_lesson.formatted_grades_for_grading.length).to eq 3
      expect(@student_lesson.formatted_grades_for_grading.map(&:mark)).to match_array [3, 2, nil]
    end

    it 'returns nulled grades for deleted grades' do
      deleted_grade = Grade.find_by(mark: 3, student_id: @student.id)
      deleted_grade.deleted_at = Time.zone.now
      deleted_grade.save

      expect(@student_lesson.formatted_grades_for_grading.length).to eq 3
      expect(@student_lesson.formatted_grades_for_grading.map(&:mark)).to match_array [nil, 2, nil]
    end

    it 'includes skill_id in the missing grade' do
      missing_grade = @student_lesson.formatted_grades_for_grading.find { |g| g.mark.nil? }
      skill_with_missing_grade = Skill.find_by skill_name: 'Discipline'
      expect(missing_grade.skill_id).to eq(skill_with_missing_grade.id)
    end
  end

  describe '#perform_grading' do
    before :each do
      @subject = create :subject_with_mindleaps_skills
      @group = create :group, chapter: create(:chapter, organization: @subject.organization)
      @student = create :enrolled_student, organization: @group.chapter.organization, groups: [@group]
      @lesson = create :lesson, group: @group, subject: @subject

      @student_lesson = StudentLesson.find_by student: @student, lesson: @lesson
    end

    describe 'student has no prior grades' do
      it 'grades the student in multiple skills' do
        @student_lesson.perform_grading({
                                          @subject.skills[0].id => @subject.skills[0].grade_descriptors[0].id,
                                          @subject.skills[1].id => @subject.skills[1].grade_descriptors[5].id,
                                          @subject.skills[2].id => @subject.skills[2].grade_descriptors[3].id
                                        })

        expect(@student.reload.grades.length).to eq 3
        expect(@student.grades.map(&:grade_descriptor_id)).to include(
          @subject.skills[0].grade_descriptors[0].id,
          @subject.skills[1].grade_descriptors[5].id,
          @subject.skills[2].grade_descriptors[3].id
        )
      end
    end

    describe 'student has prior grades' do
      before :each do
        create :grade, lesson: @lesson, student: @student, grade_descriptor: @subject.skills[0].grade_descriptors[2]
        create :grade, lesson: @lesson, student: @student, grade_descriptor: @subject.skills[1].grade_descriptors[4], deleted_at: Time.zone.now
      end

      it 'grades the student in already graded skill, changing existing grade' do
        @student_lesson.perform_grading({
                                          @subject.skills[0].id => @subject.skills[0].grade_descriptors[4].id
                                        })

        expect(@student.grades.map(&:grade_descriptor_id)).to include(@subject.skills[0].grade_descriptors[4].id)
        expect(@student.grades.map(&:grade_descriptor_id)).not_to include(@subject.skills[0].grade_descriptors[2].id)
      end

      it 'grades the student with a previously deleted grade' do
        @student_lesson.perform_grading({
                                          @subject.skills[0].id => @subject.skills[0].grade_descriptors[3].id,
                                          @subject.skills[1].id => @subject.skills[1].grade_descriptors[4].id
                                        })

        expect(@student.grades.map(&:grade_descriptor_id)).to include(@subject.skills[1].grade_descriptors[4].id)
        expect(@student.grades.map(&:deleted_at)).to contain_exactly nil, nil
      end
    end
  end
end
