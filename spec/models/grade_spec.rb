# rubocop:disable Metrics/LineLength
# rubocop:disable Style/VariableNumber

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

      it 'is invalid because student was already graded for a skill in that lesson' do
        grade = Grade.new student: @student, lesson: @lesson, grade_descriptor: create(:grade_descriptor, skill: @grade_descriptor.skill)
        expect(grade).to be_invalid
        expect(grade.errors.messages[:grade_descriptor])
          .to include "#{@student.proper_name} already scored #{@grade_descriptor.mark} in #{@grade_descriptor.skill.skill_name} on #{@lesson.date} in #{@lesson.subject.subject_name}."
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

    it 'deletes the grade if grade_descriptor is empty' do
      @grade.update_grade_descriptor nil
      expect(Grade.where(id: @grade.id)).not_to exist
    end
  end
end
