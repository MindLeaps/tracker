# frozen_string_literal: true

# == Schema Information
#
# Table name: grade_descriptors
#
#  id                :integer          not null, primary key
#  deleted_at        :datetime
#  grade_description :string
#  mark              :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  skill_id          :integer          not null
#
# Indexes
#
#  index_grade_descriptors_on_skill_id_and_mark  (skill_id,mark) UNIQUE
#
# Foreign Keys
#
#  grade_descriptors_skill_id_fk  (skill_id => skills.id)
#
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

  describe 'scope' do
    before :each do
      @skill1 = create :skill
      @skill2 = create :skill

      @gd1 = create :grade_descriptor, skill: @skill1, deleted_at: Time.zone.now
      @gd2 = create :grade_descriptor, skill: @skill1
      @gd3 = create :grade_descriptor, skill: @skill2
    end

    describe 'by_skill' do
      it 'returns only grade descriptors that belong to a particular skill' do
        expect(GradeDescriptor.by_skill(@skill1.id).length).to eq 2
        expect(GradeDescriptor.by_skill(@skill1.id)).to include @gd1, @gd2

        expect(GradeDescriptor.by_skill(@skill2.id).length).to eq 1
        expect(GradeDescriptor.by_skill(@skill2.id)).to include @gd3
      end
    end
    describe '#exclude_deleted' do
      it 'returns only grade descriptors that are not deleted' do
        expect(GradeDescriptor.exclude_deleted.all.length).to eq 2
        expect(GradeDescriptor.exclude_deleted.all).to include @gd2, @gd3
      end
    end
  end
end
