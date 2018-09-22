# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupSummary, type: :model do
  describe 'no groups present' do
    it 'returns no results' do
      expect(GroupSummary.all).to be_empty
    end
  end

  describe 'finding by id' do
    it 'finds the group summary by group id' do
      group = create :group
      expect(GroupSummary.find(group.id).group_name).to eq group.group_name
    end
  end

  describe 'fetching all group summaries' do
    before :each do
      groups = create_list :group, 3

      students1 = create_list :student, 5, group: groups[0]
      students1[3].deleted_at = Time.zone.now
      students1[4].deleted_at = Time.zone.now
      students1[3].save
      students1[4].save

      create :student, group: groups[1], deleted_at: Time.zone.now
    end

    it 'fetches all 3 groups' do
      expect(GroupSummary.all.length).to eq 3
    end

    it 'excludes deleted students from student_count' do
      expect(GroupSummary.all.map(&:student_count).sort).to eq [3, 0, 0].sort
    end
  end
end
