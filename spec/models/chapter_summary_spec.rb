# == Schema Information
#
# Table name: chapter_summaries
#
#  id                :integer          primary key
#  chapter_mlid      :string(2)
#  chapter_name      :string
#  deleted_at        :datetime
#  full_mlid         :text
#  group_count       :integer
#  organization_mlid :string(3)
#  organization_name :string
#  student_count     :integer
#  created_at        :datetime
#  updated_at        :datetime
#  organization_id   :integer
#
require 'rails_helper'

RSpec.describe ChapterSummary, type: :model do
  describe 'no groups present' do
    it 'returns no results' do
      expect(ChapterSummary.all).to be_empty
    end
  end

  describe 'fetching all chapter summaries' do
    chapters = []
    before :each do
      chapters = create_list :chapter, 3

      groups1 = create_list :group, 3, chapter: chapters[0]
      create_list :enrolled_student, 5, organization: chapters[0].organization, groups: [groups1[0]]
      create_list :enrolled_student, 3, organization: chapters[0].organization, groups: [groups1[0]], deleted_at: Time.zone.now
      create_list :enrolled_student, 3, organization: chapters[0].organization, groups: [groups1[1]]

      create_list :group, 2, chapter: chapters[0], deleted_at: Time.zone.now
      create_list :group, 2, chapter: chapters[1], deleted_at: Time.zone.now
    end

    it 'fetches all 3 groups' do
      expect(ChapterSummary.all.length).to eq 3
    end

    it 'calculates the correct group counts, excluding deleted groups' do
      expect(ChapterSummary.find(chapters[0].id).group_count).to eq 3
      expect(ChapterSummary.find(chapters[1].id).group_count).to eq 0
      expect(ChapterSummary.find(chapters[2].id).group_count).to eq 0
    end

    it 'calculates the correct student counts, excluding deleted students' do
      expect(ChapterSummary.find(chapters[0].id).student_count).to eq 8
      expect(ChapterSummary.find(chapters[1].id).student_count).to eq 0
      expect(ChapterSummary.find(chapters[2].id).student_count).to eq 0
    end
  end

  describe 'search' do
    before :each do
      @chapter1 = create :chapter, chapter_name: 'Abisamol', mlid: 'A1', organization: create(:organization, organization_name: 'Zugara')
      @chapter2 = create :chapter, chapter_name: 'Abisouena', mlid: 'C3', organization: create(:organization, organization_name: 'Aramada')
      @chapter3 = create :chapter, chapter_name: 'Milatava', mlid: 'MI', organization: create(:organization, organization_name: 'Zongorozni')
      @chapter4 = create :chapter, chapter_name: 'Zombara', mlid: 'Z9', organization: create(:organization, organization_name: 'Xibalba')
    end

    it 'finds the chapter by exact chapter name match' do
      result = ChapterSummary.search('Abisamol')
      expect(result.length).to eq 1
      expect(result.first).to eq ChapterSummary.find(@chapter1.id)
    end

    it 'finds chapters by partial chapter name match' do
      result = ChapterSummary.search('Abi')
      expect(result.length).to eq 2
      expect(result).to include ChapterSummary.find(@chapter1.id), ChapterSummary.find(@chapter2.id)
    end

    it 'finds a chapter by organization name' do
      result = ChapterSummary.search('Xiba')
      expect(result.length).to eq 1
      expect(result).to include ChapterSummary.find(@chapter4.id)
    end

    it 'finds a chapter by MLID' do
      result = ChapterSummary.search('MI')
      expect(result.length).to eq 1
      expect(result).to include ChapterSummary.find(@chapter3.id)
    end
  end
end
