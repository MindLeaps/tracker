# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Grade, type: :model do
  describe 'relationships' do
    it { should belong_to :lesson }
    it { should belong_to :student }
    it { should belong_to :grade_descriptor }
  end

  describe 'validations' do
    it { should validate_presence_of :lesson }
    it { should validate_presence_of :student }
    it { should validate_presence_of :grade_descriptor }

    describe 'uniqueness' do
      before :each do
        group = create :group
        @student = create :student, group: group
        @lesson = create :lesson, group: group
        @grade_descriptor = create :grade_descriptor

        @existing_grade = create :grade, lesson: @lesson, student: @student, grade_descriptor: @grade_descriptor
      end

      it 'is valid' do
        grade = Grade.new student: @student, lesson: @lesson, grade_descriptor: create(:grade_descriptor)
        expect(grade).to be_valid
      end

      it 'is valid if updating the grade with a new grade descriptor' do
        new_grade_descriptor = create :grade_descriptor, skill: @grade_descriptor.skill
        @existing_grade.grade_descriptor = new_grade_descriptor

        expect(@existing_grade).to be_valid
      end
      # rubocop:disable Metrics/LineLength
      it 'is invalid because student was already graded for a skill in that lesson' do
        grade = Grade.new student: @student, lesson: @lesson, grade_descriptor: create(:grade_descriptor, skill: @grade_descriptor.skill)
        expect(grade).to be_invalid
        expect(grade.errors.messages[:grade_descriptor])
          .to include "#{@student.proper_name} already scored #{@grade_descriptor.mark} in #{@grade_descriptor.skill.skill_name} on #{@lesson.date} in #{@lesson.subject.subject_name}."
      end
      # rubocop:enable Metrics/LineLength

      it 'is valid if a student was already graded for a skill in that lesson but a previous grade was deleted' do
        @existing_grade.update deleted_at: Time.zone.now
        grade = Grade.new student: @student, lesson: @lesson, grade_descriptor: create(:grade_descriptor, skill: @grade_descriptor.skill)
        expect(grade).to be_valid
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
      @grade.update_grade_descriptor @grade_descriptor2
      expect(@grade.grade_descriptor).to eq @grade_descriptor2
    end

    it 'marks the grade as deleted if grade_descriptor is empty' do
      @grade.update_grade_descriptor nil
      expect(Grade.find(@grade.id).deleted_at).not_to be nil
    end
  end

  describe '#find_duplicate' do
    before :each do
      @subject = create :subject_with_skills, number_of_skills: 2
      @grade_descriptor1 = create :grade_descriptor, skill: @subject.skills[0], mark: 1
      @grade_descriptor2 = create :grade_descriptor, skill: @subject.skills[0], mark: 2
      @grade_descriptor3 = create :grade_descriptor, skill: @subject.skills[1], mark: 2

      @lesson = create :lesson, subject: @subject

      @existing_grade = create :grade, lesson: @lesson, grade_descriptor: @grade_descriptor1
    end

    it 'finds an already existing grade for the same student, lesson and skill' do
      @new_grade = build :grade, lesson: @lesson, student: @existing_grade.student, grade_descriptor: @grade_descriptor2
      expect(@new_grade.find_duplicate).to eq @existing_grade
    end

    it 'does not find an existing grade for the same student, lesson but a different skill' do
      @new_grade = build :grade, lesson: @lesson, student: @existing_grade.student, grade_descriptor: @grade_descriptor3
      expect(@new_grade.find_duplicate).to be_nil
    end

    it 'does not find an existing grade for the same student and skill but a different lesson' do
      different_lesson = create :lesson, subject: @subject
      @new_grade = build :grade, lesson: different_lesson, student: @existing_grade.student, grade_descriptor: @grade_descriptor1
      expect(@new_grade.find_duplicate).to be_nil
    end

    it 'does not find an existing grade for the lesson and skill but a different student' do
      different_student = create :student, group: @existing_grade.student.group
      @new_grade = build :grade, lesson: @lesson, student: different_student, grade_descriptor: @grade_descriptor3
      expect(@new_grade.find_duplicate).to be_nil
    end

    it 'does not find itself' do
      expect(@existing_grade.find_duplicate).to be_nil
    end
  end
end
