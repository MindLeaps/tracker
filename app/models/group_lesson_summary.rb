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
class GroupLessonSummary < ApplicationRecord
  self.primary_key = :lesson_id
  belongs_to :chapter
  belongs_to :group

  def readonly?
    true
  end

  def self.around(lesson, number_of_elements)
    before = select_for_graphing(GroupLessonSummary.where('lesson_date <= ? AND group_id = ?', lesson.date, lesson.group_id), :desc, number_of_elements)
    after = select_for_graphing(GroupLessonSummary.where('lesson_date > ? AND group_id = ?', lesson.date, lesson.group_id), :asc, number_of_elements)
    process_around_result(lesson, before.reverse + after, number_of_elements)
  end

  def self.select_for_graphing(relation, sorting_direction, number_of_elements)
    relation
      .order(lesson_date: sorting_direction).limit(number_of_elements)
      .select(Arel.sql('extract(EPOCH FROM lesson_date) :: INT AS timestamp'), :average_mark, :lesson_date, :lesson_id)
  end

  def self.process_around_result(lesson, result, number_of_elements)
    index = result.index { |l| l.lesson_id == lesson.id }
    index = find_closest_index(result, lesson) if index.nil?
    number_of_elements = [result.size, number_of_elements].min
    return [] if result == []

    result[
      (index - (number_of_elements / 2)).clamp(0, result.size - number_of_elements),
      number_of_elements
    ]
  end

  # rubocop:disable Lint/UnreachableLoop
  def self.find_closest_index(lessons, lesson)
    previous_diff = nil
    lessons.each_with_index.reduce(nil) do |previous_closest_i, (l, i)|
      diff = (lesson.date.to_time.to_i - l.lesson_date.to_time.to_i).abs
      if previous_diff.nil? || diff < previous_diff
        previous_diff = diff
        return i
      end
      return previous_closest_i
    end
  end
  # rubocop:enable Lint/UnreachableLoop
end
