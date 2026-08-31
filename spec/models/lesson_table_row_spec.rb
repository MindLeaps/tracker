require 'rails_helper'

RSpec.describe LessonTableRow, type: :model do
  describe '.build_for' do
    before :each do
      @subject = create :subject
      @group = create :group, chapter: create(:chapter, organization: @subject.organization)
      @lesson = create :lesson, group: @group, subject: @subject

      @first_student = create :enrolled_student, organization: @group.chapter.organization, groups: [@group]
      @second_student = create :enrolled_student, organization: @group.chapter.organization, groups: [@group]
      @ungraded_student = create :enrolled_student, organization: @group.chapter.organization, groups: [@group]
      @deleted_student = create :enrolled_student, organization: @group.chapter.organization, groups: [@group], deleted_at: Time.zone.now

      @first_skill = create(:skill_in_subject, subject: @subject)
      @second_skill = create(:skill_in_subject, subject: @subject)

      @first_grade = create :grade, student: @first_student, lesson: @lesson, skill: @first_skill, mark: 1
      @second_grade = create :grade, student: @first_student, lesson: @lesson, skill: @second_skill, mark: 5
      @third_grade = create :grade, student: @second_student, lesson: @lesson, skill: @first_skill, mark: 1

      create :grade, student: @second_student, lesson: @lesson, skill: @second_skill, mark: 5, deleted_at: Time.zone.now

      # A grade for the deleted student, to prove it's excluded from every aggregate below.
      create :grade, student: @deleted_student, lesson: @lesson, skill: @first_skill, mark: 5
    end

    it 'computes group_student_count from active, non-deleted enrollments regardless of grading' do
      row = LessonTableRow.build_for([@lesson]).first
      expect(row.group_student_count).to eq 3 # first, second, ungraded - not the deleted student
    end

    it 'computes graded_student_count as students with at least one grade' do
      row = LessonTableRow.build_for([@lesson]).first
      expect(row.graded_student_count).to eq 2 # first and second student, not ungraded
    end

    it 'averages each student\'s own average mark, not a flat average over every grade' do
      row = LessonTableRow.build_for([@lesson]).first

      first_student_average = (@first_grade.mark + @second_grade.mark) / 2.0 # 3
      second_student_average = @third_grade.mark # 1
      expect(row.average_mark).to eq ((first_student_average + second_student_average) / 2).round(2) # 2, not (1+5+1)/3 = 2.33
    end

    it 'populates the display fields from the lesson\'s associations' do
      row = LessonTableRow.build_for([@lesson]).first

      expect(row.id).to eq @lesson.id
      expect(row.date).to eq @lesson.date
      expect(row.group_name).to eq @group.group_name
      expect(row.chapter_name).to eq @group.chapter_name
      expect(row.subject_name).to eq @subject.subject_name
    end

    context 'a lesson with no enrolled students' do
      before :each do
        @empty_group = create :group, chapter: @group.chapter
        @empty_lesson = create :lesson, group: @empty_group, subject: @subject
      end

      it 'still returns a row, with zeroed counts and no average' do
        row = LessonTableRow.build_for([@empty_lesson]).first

        expect(row.group_student_count).to eq 0
        expect(row.graded_student_count).to eq 0
        expect(row.average_mark).to be_nil
      end
    end

    it 'builds rows for multiple lessons in a single call, preserving order' do
      other_lesson = create :lesson, group: @group, subject: @subject, date: @lesson.date - 1.day

      rows = LessonTableRow.build_for([@lesson, other_lesson])

      expect(rows.map(&:id)).to eq [@lesson.id, other_lesson.id]
      expect(rows.last.graded_student_count).to eq 0
    end

    it 'issues one aggregation query regardless of how many lessons are on the page (no N+1)' do
      other_lessons = create_list :lesson, 9, group: @group, subject: @subject

      queries = []
      subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |*, payload|
        queries << payload[:sql] if payload[:sql].include?('WITH selected_lessons AS')
      end

      LessonTableRow.build_for([@lesson] + other_lessons)

      ActiveSupport::Notifications.unsubscribe(subscriber)

      expect(queries.size).to eq 1
    end
  end
end
