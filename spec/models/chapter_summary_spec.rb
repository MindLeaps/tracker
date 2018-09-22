# frozen_string_literal: true

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
      create_list :student, 5, group: groups1[0]
      create_list :student, 3, group: groups1[0], deleted_at: Time.zone.now
      create_list :student, 3, group: groups1[1]

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
end
