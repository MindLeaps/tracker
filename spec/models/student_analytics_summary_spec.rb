# == Schema Information
#
# Table name: student_analytics_summaries
#
#  id                 :integer          primary key
#  enrolled_group_ids :bigint           is an Array
#  first_name         :string
#  last_name          :string
#  old_group_id       :integer
#
require 'rails_helper'

RSpec.describe StudentAnalyticsSummary, type: :model do
  describe 'when no enrollments are present' do
    before :each do
      create_list :student, 10
    end

    it 'returns no results' do
      expect(StudentAnalyticsSummary.all).to be_empty
    end
  end

  describe 'when enrollments are present' do
    it 'returns all student summaries' do
      @organization = create :organization
      @chapter = create :chapter, organization: @organization
      @groups = create_list :group, 2, chapter: @chapter
      create_list :enrolled_student, 10, organization: @organization, groups: @groups

      result = StudentAnalyticsSummary.all

      expect(result.size).to eq 10
      expect(result.pluck(:enrolled_group_ids).flatten.uniq).to match_array(@groups.pluck(:id))
    end
  end

  describe 'methods' do
    describe '#proper_name' do
      it 'returns the proper name of the student' do
        @group = create :group
        create :enrolled_student, organization: @group.chapter.organization, groups: [@group], first_name: 'Test', last_name: 'Student'

        expect(StudentAnalyticsSummary.first.proper_name).to eq 'Student, Test'
      end
    end
  end
end
