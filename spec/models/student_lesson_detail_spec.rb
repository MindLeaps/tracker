# == Schema Information
#
# Table name: student_lesson_details
#
#  average_mark       :decimal(, )
#  date               :date
#  first_name         :string
#  grade_count        :bigint
#  last_name          :string
#  lesson_deleted_at  :datetime
#  skill_marks        :jsonb
#  student_deleted_at :datetime
#  lesson_id          :uuid
#  student_id         :integer
#  subject_id         :integer
#
require 'rails_helper'

RSpec.describe StudentLessonDetail, type: :model do
  describe 'Lesson Marks calculation' do
    context 'student that attended a single lesson' do
      before :each do
        @org = create :organization
        @chapter = create :chapter, organization: @org
        @group = create :group, chapter: @chapter
        @student = create :graded_student, grades: { 'Memorization' => [3], 'Grit' => [2] }, organization: @org, groups: [@group]
      end
      it 'calculates student marks correctly' do
        expect(StudentLessonDetail.first.skill_names_marks).to eq 'Memorization' => 3, 'Grit' => 2
      end
    end

    context 'student that attended multiple lessons' do
      before :each do
        @student = create :graded_student, grades: {
          'Memorization' => [1, 2, 3],
          'Grit' => [2, 1, 2, 1],
          'Teamwork' => [3, 4, 4, 5],
          'Discipline' => [2, 2, 2, 2],
          'Self-Esteem' => [6, 5, 6, 6],
          'Creativity & Self-Expression' => [5, 4],
          'Language' => [1, 1, 2]
        }
      end
      it 'returns the correct marks for the last lesson' do
        expect(StudentLessonDetail.order(:date).last.skill_names_marks).to eq(
          'Grit' => 1,
          'Teamwork' => 5,
          'Discipline' => 2,
          'Self-Esteem' => 6
        )
      end
      it 'calculates the average marks correctly' do
        averages = StudentLessonDetail.order(:date).map(&:average_mark)

        expect(averages[0]).to be_within(0.01).of 2.86
        expect(averages[1]).to be_within(0.01).of 2.71
        expect(averages[2]).to be_within(0.01).of 3.17
        expect(averages[3]).to be_within(0.01).of 3.5
      end
    end
  end

  describe 'scopes' do
    describe '#exclude_empty' do
      before :each do
        @student = create :graded_student, grades: { 'Memorization' => [3, nil, nil, 1], 'Grit' => [2], 'Teamwork' => [] }
      end
      it 'returns only records that have at least a single grade' do
        expect(StudentLessonDetail.exclude_empty.all.length).to eq 2
      end
    end
  end
end
