require 'rails_helper'

RSpec.describe GradeDescriptor, type: :model do
  describe 'relationships' do
    it { should belong_to :skill }
  end

  describe 'validations' do
    it { should validate_presence_of :skill }
    it { should validate_presence_of :mark }

    describe 'uniqueness' do
      before :each do
        @skill = create :skill
        create :grade_descriptor, mark: 1, skill: @skill
      end

      it 'is valid' do
        expect(build(:grade_descriptor, mark: 2, skill: @skill)).to be_valid
      end

      it 'is invalid because of duplicated mark in the same skill' do
        expect(build(:grade_descriptor, mark: 1, skill: @skill)).to be_invalid
      end
    end
  end
end
