# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupLessonSummary, type: :model do
  describe '#readonly?' do
    before :each do
      @group = create :group
      create :graded_student, group: @group, grades: { 'skill' => [1] }
    end

    it 'returns false' do
      expect(GroupLessonSummary.first.readonly?).to eq true
    end
  end

  describe 'query' do
    before :each do
      @group = create :group
      @student = create :graded_student, group: @group, grades: {
        'Memorization' => [1, 2, 4],
        'Grit' => [2, 4]
      }
    end

    it 'returns group lesson summaries with correct marks and grade count' do
      result = GroupLessonSummary.all
      expect(result.size).to eq 3

      expect(result[0].grade_count).to eq 2
      expect(result[0].average_mark).to eq 1.5

      expect(result[1].grade_count).to eq 2
      expect(result[1].average_mark).to eq 3

      expect(result[2].grade_count).to eq 1
      expect(result[2].average_mark).to eq 4
    end
  end

  describe '#around' do
    before :each do
      @group = create :group
      create :graded_student, group: @group, grades: {
        'Memorization' => [1, 2, 1, 3, 2, 3, 4],
        'Grit' => [2, 3, 5, 3, 4, 5, 6]
      }
    end

    it 'returns the target group lesson summary and 2 before and after it' do
      lesson = Lesson.order(:date).all[3]
      result = GroupLessonSummary.around lesson, 5

      expect(result.size).to eq 5
      expect(result[0].average_mark).to eq 2.5
      expect(result[1].average_mark).to eq 3
      expect(result[2].average_mark).to eq 3
      expect(result[3].average_mark).to eq 3
      expect(result[4].average_mark).to eq 4
    end

    it 'bounds the result to the first lesson' do
      lesson = Lesson.order(:date).all[1]
      result = GroupLessonSummary.around lesson, 5

      expect(result.size).to eq 5
      expect(result[0].average_mark).to eq 1.5
      expect(result[1].average_mark).to eq 2.5
      expect(result[2].average_mark).to eq 3
      expect(result[3].average_mark).to eq 3
      expect(result[4].average_mark).to eq 3
    end

    it 'bounds the result to the last lesson' do
      lesson = Lesson.order(:date).all[6]
      result = GroupLessonSummary.around lesson, 5

      expect(result.size).to eq 5
      expect(result[0].average_mark).to eq 3
      expect(result[1].average_mark).to eq 3
      expect(result[2].average_mark).to eq 3
      expect(result[3].average_mark).to eq 4
      expect(result[4].average_mark).to eq 5
    end

    it 'correctly bounds the result when the number of elements requested is higher than the count' do
      lesson = Lesson.order(:date).all[1]
      result = GroupLessonSummary.around lesson, 8

      expect(result.size).to eq 7
      expect(result[0].average_mark).to eq 1.5
      expect(result[1].average_mark).to eq 2.5
      expect(result[2].average_mark).to eq 3
      expect(result[3].average_mark).to eq 3
      expect(result[4].average_mark).to eq 3
      expect(result[5].average_mark).to eq 4
      expect(result[6].average_mark).to eq 5
    end
  end
end
