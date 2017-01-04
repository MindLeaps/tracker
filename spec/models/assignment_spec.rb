# frozen_string_literal: true
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
