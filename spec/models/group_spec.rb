# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Group, type: :model do
  describe 'scopes' do
    before :each do
      @group1 = create :group
      @group2 = create :group
      @group3 = create :group, deleted_at: Time.zone.now
    end

    describe 'exclude_deleted' do
      it 'returns only non-deleted groups' do
        expect(Group.exclude_deleted.length).to eq 2
        expect(Group.exclude_deleted).to include @group1, @group2
      end
    end
  end
end
