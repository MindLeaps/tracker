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
    stats_by_lesson_id = statistics_for(lesson_ids)

    lessons.map do |lesson|
      build_row(lesson, stats_by_lesson_id[lesson.id] || [0, 0, nil])
    end
  end

  def self.statistics_for(lesson_ids)
    return {} if lesson_ids.empty?

    sql = sanitize_sql_array([Sql.lesson_table_row_statistics, { lesson_ids: }])

    connection.select_rows(sql).to_h do |lesson_id, group_count, graded_count, average_mark|
      [lesson_id, [group_count, graded_count, average_mark]]
    end
  end

  def self.build_row(lesson, statistics)
    group_student_count, graded_student_count, average_mark = statistics
    new(id: lesson.id,
        date: lesson.date,
        group_id: lesson.group_id,
        group_name: lesson.group.group_name,
        chapter_name: lesson.group.chapter_name,
        subject_name: lesson.subject.subject_name,
        group_student_count:,
        graded_student_count:,
        average_mark:)
  end

  private_class_method :statistics_for
  private_class_method :build_row
end
