# == Schema Information
#
# Table name: group_lesson_summaries
#
#  attendance         :float
#  average_mark       :float
#  grade_count        :bigint
#  group_chapter_name :text
#  lesson_date        :date
#  chapter_id         :integer
#  group_id           :integer
#  lesson_id          :uuid             primary key
#  subject_id         :integer
#
require 'rails_helper'

RSpec.describe GroupLessonSummary, type: :model do
  describe 'relationships' do
    it { should belong_to :chapter }
    it { should belong_to :group }
  end

  describe '#readonly?' do
    before :each do
      @group = create :group
      @student = create :graded_student, organization: @group.chapter.organization, groups: [@group], grades: { 'skill' => [1] }
    end

    it 'returns false' do
      expect(GroupLessonSummary.first.readonly?).to eq true
    end
  end

  describe 'query' do
    before :each do
      @group = create :group
      @student = create :graded_student, organization: @group.chapter.organization, groups: [@group], grades: {
        'Memorization' => [1, 2, 4],
        'Grit' => [2, 4]
      }
    end

    it 'returns group lesson summaries with average marks and grade count and attendance' do
      result = GroupLessonSummary.all
      expect(result.size).to eq 3

      expect(result[0].grade_count).to eq 2
      expect(result[0].average_mark).to eq 1.5
      expect(result[0].attendance).to eq 100.00

      expect(result[1].grade_count).to eq 2
      expect(result[1].average_mark).to eq 3
      expect(result[0].attendance).to eq 100.00

      expect(result[2].grade_count).to eq 1
      expect(result[2].average_mark).to eq 4
      expect(result[0].attendance).to eq 100.00
    end
  end

  describe '#around' do
    before :each do
      @group = create :group
      @student = create :graded_student, organization: @group.chapter.organization, groups: [@group], grades: {
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

  describe 'calculations' do
    before :each do
      subject = create :subject
      @group = create :group
      @lesson = create(:lesson, group: @group, subject:, date: Time.zone.now)
      @first_student = create :enrolled_student, organization: @group.chapter.organization, groups: [@group]
      @second_student = create :enrolled_student, organization: @group.chapter.organization, groups: [@group]
      @ungraded_student = create :enrolled_student, organization: @group.chapter.organization, groups: [@group]
      @deleted_student = create :enrolled_student, organization: @group.chapter.organization, groups: [@group], deleted_at: Time.zone.now

      @first_skill = create(:skill_in_subject, subject:)
      @second_skill = create(:skill_in_subject, subject:)
      @removed_skill = create(:skill_removed_from_subject, subject:)

      @first_grade = create :grade, student: @first_student, lesson: @lesson, skill: @first_skill, mark: 1
      @second_grade = create :grade, student: @first_student, lesson: @lesson, skill: @second_skill, mark: 5
      @third_grade = create :grade, student: @second_student, lesson: @lesson, skill: @second_skill, mark: 1
      @grade_for_deleted_student = create :grade, student: @deleted_student, lesson: @lesson, skill: @first_skill, mark: 5
      @deleted_grade = create :grade, student: @first_student, lesson: @lesson, skill: @removed_skill, mark: 1, deleted_at: Time.zone.now
    end

    it 'returns a correct average mark' do
      summary = GroupLessonSummary.find_by!(lesson_id: @lesson.id)
      first_student_average = (@first_grade.mark + @second_grade.mark) / 2
      second_student_average = @third_grade.mark

      expect(summary.average_mark).to eq((first_student_average + second_student_average) / 2)
    end

    it 'returns the count of active and undeleted grades' do
      summary = GroupLessonSummary.find_by!(lesson_id: @lesson.id)

      expect(summary.grade_count).to eq 3
    end

    it 'returns the attendance percentage for the present students' do
      summary = GroupLessonSummary.find_by!(lesson_id: @lesson.id)

      expect(summary.attendance).to be_between(2.0 / 3 * 100, 67)
    end
  end
end
