# == Schema Information
#
# Table name: grades
#
#  id                  :integer          not null, primary key
#  deleted_at          :datetime
#  mark                :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  grade_descriptor_id :integer          not null
#  lesson_id           :uuid             not null
#  skill_id            :bigint           not null
#  student_id          :integer          not null
#
# Indexes
#
#  index_grades_on_grade_descriptor_id  (grade_descriptor_id)
#  index_grades_on_lesson_id            (lesson_id)
#  index_grades_on_skill_id             (skill_id)
#  index_grades_on_student_id           (student_id)
#
# Foreign Keys
#
#  fk_rails_...                   (skill_id => skills.id)
#  grades_grade_descriptor_id_fk  (grade_descriptor_id => grade_descriptors.id)
#  grades_lesson_id_fk            (lesson_id => lessons.id)
#  grades_student_id_fk           (student_id => students.id)
#
require 'rails_helper'

RSpec.describe Grade, type: :model do
  describe 'relationships' do
    it { should belong_to :lesson }
    it { should belong_to :student }
    it { should belong_to :grade_descriptor }
  end

  describe 'validations' do
    describe 'uniqueness' do
      before :each do
        @group = create :group
        @student = create :student, organization: @group.chapter.organization, groups: [@group]
        @lesson = create :lesson, group: @group
        @grade_descriptor = create :grade_descriptor
        @existing_grade = create :grade, lesson: @lesson, student: @student, grade_descriptor: @grade_descriptor
      end

      it 'is valid' do
        grade = Grade.new student: @student, lesson: @lesson, grade_descriptor: create(:grade_descriptor)
        expect(grade).to be_valid
      end

      it 'is valid if updating the grade with a new grade descriptor' do
        Bullet.enable = false # Bullet throws false positive here
        new_grade_descriptor = create :grade_descriptor, skill: @grade_descriptor.skill
        @existing_grade.grade_descriptor = new_grade_descriptor

        expect(@existing_grade).to be_valid
        Bullet.enable = true
      end

      it 'is invalid because student was already graded for a skill in that lesson' do
        grade = Grade.new student: @student, lesson: @lesson, grade_descriptor: create(:grade_descriptor, skill: @grade_descriptor.skill)
        expect(grade).to be_invalid
        expect(grade.errors.messages[:grade_descriptor])
          .to include "#{@student.proper_name} already scored #{@grade_descriptor.mark} in #{@grade_descriptor.skill.skill_name} on #{@lesson.date} in #{@lesson.subject.subject_name}."
      end

      it 'is invalid if a deleted grade already exists' do
        @existing_grade.update deleted_at: Time.zone.now
        grade = Grade.new student: @student, lesson: @lesson, grade_descriptor: create(:grade_descriptor, skill: @grade_descriptor.skill)
        expect(grade).to be_invalid
      end
    end
  end

  describe 'scopes' do
    before :each do
      @student1 = create :student
      @student2 = create :student
      @deleted_student = create :student, deleted_at: Time.zone.now

      @lesson1 = create :lesson
      @lesson2 = create :lesson

      @grade1 = create :grade, student: @student1, lesson: @lesson1, created_at: 4.days.ago, updated_at: 2.days.ago
      @grade2 = create :grade, student: @student1, lesson: @lesson2
      @grade3 = create :grade, student: @student2, lesson: @lesson1
      @deleted_grade = create :grade, deleted_at: Time.zone.now

      @grade_of_deleted = create :grade, student: @deleted_student, created_at: 5.days.ago, updated_at: 2.days.ago
    end

    describe '#by_group' do
      it 'returns grades scoped by student' do
        expect(Grade.by_student(@student1.id).all.length).to eq 2
        expect(Grade.by_student(@student1.id).all).to include @grade1, @grade2
      end
    end

    describe '#by_lesson' do
      it 'returns grades scoped by lesson' do
        expect(Grade.by_lesson(@lesson1.id).all.length).to eq 2
        expect(Grade.by_lesson(@lesson1.id).all).to include @grade1, @grade3
      end
    end

    describe '#after_timestamp' do
      it 'returns grades created or updated after timestamp' do
        expect(Grade.after_timestamp(Time.zone.today.beginning_of_day.iso8601).length).to eq 3
        expect(Grade.after_timestamp(Time.zone.today.beginning_of_day.iso8601)).to include @grade2, @grade3, @deleted_grade
      end
    end

    describe '#exclude_deleted' do
      it 'returns only grades that are not deleted' do
        expect(Grade.exclude_deleted.all.length).to eq 4
        expect(Grade.exclude_deleted.all).to include @grade1, @grade2, @grade3
        expect(Grade.exclude_deleted.all).not_to include @deleted_grade
      end
    end

    describe '#exclude_deleted_students' do
      it 'returns only grades of non-deleted students' do
        expect(Grade.exclude_deleted_students.all.length).to eq 4
        expect(Grade.exclude_deleted_students.all).to include @grade1, @grade2, @grade3, @deleted_grade
        expect(Grade.exclude_deleted_students.all).not_to include @grade_of_deleted
      end
    end
  end

  describe '#update_grade_descriptor' do
    before :each do
      @subject = create :subject_with_skills, number_of_skills: 1
      @grade_descriptor1 = create :grade_descriptor, skill: @subject.skills[0], mark: 1
      @grade_descriptor2 = create :grade_descriptor, skill: @subject.skills[0], mark: 2

      @grade = create :grade, grade_descriptor: @grade_descriptor1
    end

    it 'updates the grade_descriptor' do
      Bullet.enable = false # Bullet throws false positive here
      @grade.update_grade_descriptor @grade_descriptor2
      expect(@grade.grade_descriptor).to eq @grade_descriptor2
      Bullet.enable = true
    end

    it 'marks the grade as deleted if grade_descriptor is empty' do
      @grade.update_grade_descriptor nil
      expect(Grade.find(@grade.id).deleted_at).not_to be nil
    end
  end

  describe '#find_duplicate' do
    before :each do
      @subject = create :subject_with_skills, number_of_skills: 2
      @group = create :group, chapter: create(:chapter, organization: @subject.organization)
      @enrolled_student = create :enrolled_student, organization: @group.chapter.organization, groups: [@group]

      @grade_descriptor1 = create :grade_descriptor, skill: @subject.skills[0], mark: 1
      @grade_descriptor2 = create :grade_descriptor, skill: @subject.skills[0], mark: 2
      @grade_descriptor3 = create :grade_descriptor, skill: @subject.skills[1], mark: 2

      @lesson = create :lesson, subject: @subject

      @existing_grade = create :grade, student: @enrolled_student, lesson: @lesson, grade_descriptor: @grade_descriptor1
    end

    it 'finds an already existing grade for the same student, lesson and skill' do
      @new_grade = build :grade, lesson: @lesson, student: @enrolled_student, grade_descriptor: @grade_descriptor2
      expect(@new_grade.find_duplicate).to eq @existing_grade
    end

    it 'does not find an existing grade for the same student, lesson but a different skill' do
      @new_grade = build :grade, lesson: @lesson, student: @enrolled_student, grade_descriptor: @grade_descriptor3
      expect(@new_grade.find_duplicate).to be_nil
    end

    it 'does not find an existing grade for the same student and skill but a different lesson' do
      different_lesson = create :lesson, subject: @subject
      @new_grade = build :grade, lesson: different_lesson, student: @enrolled_student, grade_descriptor: @grade_descriptor1
      expect(@new_grade.find_duplicate).to be_nil
    end

    it 'does not find an existing grade for the lesson and skill but a different student' do
      different_student = create :enrolled_student, organization: @enrolled_student.enrollments[0].group.chapter.organization, groups: [@enrolled_student.enrollments[0].group]
      @new_grade = build :grade, lesson: @lesson, student: different_student, grade_descriptor: @grade_descriptor3
      expect(@new_grade.find_duplicate).to be_nil
    end

    it 'does not find itself' do
      expect(@existing_grade.find_duplicate).to be_nil
    end
  end
end
