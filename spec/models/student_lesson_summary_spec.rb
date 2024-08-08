# == Schema Information
#
# Table name: student_lesson_summaries
#
#  average_mark :decimal(, )
#  deleted_at   :datetime
#  first_name   :string
#  grade_count  :bigint
#  last_name    :string
#  lesson_date  :date
#  skill_count  :bigint
#  group_id     :integer
#  lesson_id    :uuid
#  student_id   :integer
#  subject_id   :integer
#
require 'rails_helper'

RSpec.describe StudentLessonSummary, type: :model do
  describe 'scopes' do
    describe '#table_order_lesson_students' do
      before :each do
        @group = create :group
        @abimz = create :student, last_name: 'Abimz', first_name: 'Zima', group: @group
        @zimba = create :student, last_name: 'Zimba', first_name: 'Azim', group: @group
        [@abimz, @zimba].each { |s| create :enrollment, student: s, group: @group, active_since: 1.year.ago }

        create :lesson, group: @group
      end

      it 'orders summaries by student last name' do
        summaries = StudentLessonSummary.table_order_lesson_students(key: :last_name, order: :asc).all
        expect(summaries.map(&:last_name)).to eq [@abimz.last_name, @zimba.last_name]

        summaries = StudentLessonSummary.table_order_lesson_students(key: :last_name, order: :desc).all
        expect(summaries.map(&:last_name)).to eq [@zimba.last_name, @abimz.last_name]
      end
    end
  end

  describe 'values' do
    before :each do
      subject = create :subject
      @group = create :group
      @lesson = create(:lesson, group: @group, subject:)
      @student = create :student, group: @group
      create :enrollment, group: @group, student: @student
    end

    it 'show the lesson date' do
      summaries = StudentLessonSummary.all
      summaries.each do |summary|
        expect(summary.lesson_date).to eq @lesson.date
      end
    end
  end

  describe 'calculations' do
    before :each do
      subject = create :subject
      @group = create :group
      @lesson = create(:lesson, group: @group, subject:)
      @first_student = create :student, group: @group
      @second_student = create :student, group: @group
      [@first_student, @second_student].each { |s| create :enrollment, student: s, group: @group, active_since: 1.year.ago }

      @first_skill = create(:skill_in_subject, subject:)
      @second_skill = create(:skill_in_subject, subject:)
      @empty_skill = create(:skill_in_subject, subject:)
      @removed_skill = create(:skill_removed_from_subject, subject:)

      @first_grade = create :grade, student: @first_student, lesson: @lesson, skill: @first_skill, mark: 1
      @second_grade = create :grade, student: @first_student, lesson: @lesson, skill: @second_skill, mark: 5
      @deleted_grade = create :grade, student: @first_student, lesson: @lesson, skill: @removed_skill, mark: 1, deleted_at: Time.zone.now
    end

    it 'only counts undeleted skills' do
      summaries = StudentLessonSummary.all
      summaries.each do |summary|
        expect(summary.skill_count).to eq 3
      end
    end

    it 'only counts grades of undeleted skills' do
      first_summary = StudentLessonSummary.find_by!(student_id: @first_student.id)
      second_summary = StudentLessonSummary.find_by!(student_id: @second_student.id)

      expect(first_summary.grade_count).to eq 2
      expect(second_summary.grade_count).to eq 0
    end

    it 'only uses grades of undeleted & graded skills to calculate average mark' do
      first_summary = StudentLessonSummary.find_by!(student_id: @first_student.id)
      second_summary = StudentLessonSummary.find_by!(student_id: @second_student.id)

      expect(first_summary.average_mark).to eq((@first_grade.mark + @second_grade.mark) / 2)
      expect(second_summary.average_mark).to be nil
    end
  end
end
