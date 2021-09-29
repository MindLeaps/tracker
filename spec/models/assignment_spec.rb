# frozen_string_literal: true

# == Schema Information
#
# Table name: assignments
#
#  id         :integer          not null, primary key
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  skill_id   :integer          not null
#  subject_id :integer          not null
#
# Indexes
#
#  index_assignments_on_skill_id    (skill_id)
#  index_assignments_on_subject_id  (subject_id)
#
# Foreign Keys
#
#  assignments_skill_id_fk    (skill_id => skills.id)
#  assignments_subject_id_fk  (subject_id => subjects.id)
#
require 'rails_helper'

RSpec.describe Assignment, type: :model do
  describe 'relationships' do
    it { should belong_to :skill }
    it { should belong_to :subject }
  end

  describe 'validations' do
    it { should validate_presence_of :skill }
    it { should validate_presence_of :subject }
  end

  describe '#destroy' do
    before :each do
      @assignment = create :assignment
      @assignment.destroy
    end

    it 'sets the deleted_at field to current time' do
      expect(@assignment.reload.deleted_at).to be_within(1.second).of Time.zone.now
    end
  end
end
