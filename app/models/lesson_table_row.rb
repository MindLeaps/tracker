# == Schema Information
#
# Table name: lesson_table_rows
#
#  id                   :uuid
#  average_mark         :decimal(, )
#  chapter_name         :string
#  date                 :date
#  deleted_at           :datetime
#  graded_student_count :bigint
#  group_name           :string
#  group_student_count  :bigint
#  subject_name         :string
#  created_at           :datetime
#  updated_at           :datetime
#  group_id             :integer
#  subject_id           :integer
#
class LessonTableRow < ApplicationRecord
  belongs_to :group

  def readonly?
    true
  end

  def self.build_for(lessons)
    lesson_ids = lessons.map(&:id)
    stats_by_lesson_id = StudentLessonSummary
                         .where(lesson_id: lesson_ids, deleted_at: nil)
                         .group(:lesson_id)
                         .pluck(
                           :lesson_id,
                           Arel.sql('COUNT(*)'),
                           Arel.sql('COUNT(*) FILTER (WHERE grade_count > 0)'),
                           Arel.sql('ROUND(AVG(average_mark)::numeric, 2)')
                         ).to_h { |lesson_id, group_count, graded_count, avg_mark| [lesson_id, [group_count, graded_count, avg_mark]] }

    lessons.map do |lesson|
      group_student_count, graded_student_count, average_mark = stats_by_lesson_id[lesson.id] || [0, 0, nil]

      new(
        id: lesson.id,
        date: lesson.date,
        group_id: lesson.group_id,
        group_name: lesson.group.group_name,
        chapter_name: lesson.group.chapter_name,
        subject_name: lesson.subject.subject_name,
        group_student_count:,
        graded_student_count:,
        average_mark:
      )
    end
  end
end
