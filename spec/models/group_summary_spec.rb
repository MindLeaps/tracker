# == Schema Information
#
# Table name: group_summaries
#
#  id                :integer          primary key
#  chapter_mlid      :string(2)
#  chapter_name      :string
#  deleted_at        :datetime
#  full_mlid         :text
#  group_name        :string
#  mlid              :string(2)
#  organization_mlid :string(3)
#  organization_name :string
#  student_count     :bigint
#  created_at        :datetime
#  chapter_id        :integer
#  organization_id   :integer
#
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
      org = create :organization
      groups = create_list :group, 3, chapter: create(:chapter, organization: org)

      students = create_list :enrolled_student, 5, organization: org, groups: groups
      students[3].deleted_at = Time.zone.now
      students[4].deleted_at = Time.zone.now
      students[3].save
      students[4].save

      create :enrolled_student, organization: org, groups: [groups[0]]
      create :enrolled_student, organization: org, groups: [groups[1]], deleted_at: Time.zone.now
      new_student = create :enrolled_student, organization: org, groups: [groups[2]]

      new_student.enrollments.last.active_since = 1.day.from_now
      new_student.save
    end

    it 'fetches all 3 groups' do
      expect(GroupSummary.all.length).to eq 3
    end

    it 'excludes deleted and not enrolled students from student_count' do
      expect(GroupSummary.all.map(&:student_count).sort).to eq [4, 3, 3].sort
    end
  end

  describe 'search' do
    before :each do
      @group1 = create :group, group_name: 'Abisamol'
      @group2 = create :group, group_name: 'Abisouena'
      @group3 = create :group, group_name: 'Milatava', chapter: create(:chapter, chapter_name: 'Xalnatutron')
      @group4 = create :group, group_name: 'Zombara', chapter: create(:chapter, organization: create(:organization, organization_name: 'Xibalba'))
    end

    it 'finds the group by exact group name match' do
      result = GroupSummary.search('Abisamol')
      expect(result.length).to eq 1
      expect(result.first).to eq GroupSummary.find(@group1.id)
    end

    it 'finds groups by partial group name match' do
      result = GroupSummary.search('Abi')
      expect(result.length).to eq 2
      expect(result).to include GroupSummary.find(@group1.id), GroupSummary.find(@group2.id)
    end

    it 'finds a group by chapter name' do
      result = GroupSummary.search('Xalna')
      expect(result.length).to eq 1
      expect(result).to include GroupSummary.find(@group3.id)
    end

    it 'finds a group by organization name' do
      result = GroupSummary.search('Xiba')
      expect(result.length).to eq 1
      expect(result).to include GroupSummary.find(@group4.id)
    end
  end
end
