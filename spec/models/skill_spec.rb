require 'rails_helper'

RSpec.describe Skill, type: :model do
  describe 'relationships' do
    it { should belong_to :organization }
    it { should have_many(:grade_descriptors).dependent :destroy }
    it { should have_many(:assignments).dependent :destroy }
    it { should have_many(:subjects).through :assignments }
  end

  describe 'validations' do
    it { should validate_presence_of :skill_name }
    it { should validate_presence_of :organization }

    describe 'validate grade descriptors' do
      let(:org) { create :organization }
      it 'is valid' do
        desc1 = GradeDescriptor.new mark: 1
        desc2 = GradeDescriptor.new mark: 2
        skill = Skill.new skill_name: 'Valid Skill', organization: org, grade_descriptors: [desc1, desc2]
        expect(skill).to be_valid
      end

      it 'is not valid because grade descriptors have duplicated marks in the same skill' do
        desc1 = GradeDescriptor.new mark: 1
        desc2 = GradeDescriptor.new mark: 1
        skill = Skill.new skill_name: 'Valid Skill', organization: org, grade_descriptors: [desc1, desc2]
        expect(skill).to be_invalid
      end

      it 'is not valid because grade descriptor is not valid' do
        desc = GradeDescriptor.new
        skill = Skill.new skill_name: 'Valid Skill', organization: org, grade_descriptors: [desc]
        expect(skill).to be_invalid
      end
    end
  end
end
