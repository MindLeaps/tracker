# frozen_string_literal: true

class GroupLessonSummary < ApplicationRecord
  self.primary_key = :lesson_uid
  belongs_to :chapter

  def readonly?
    true
  end

  def around(number_of_elements)
    before = select_for_graphing(GroupLessonSummary.where('lesson_date <= ? AND group_id = ?', lesson_date, group_id), :desc, number_of_elements)
    after = select_for_graphing(GroupLessonSummary.where('lesson_date > ? AND group_id = ?', lesson_date, group_id), :asc, number_of_elements)
    process_around_result(before.reverse + after, number_of_elements)
  end

  private

  def select_for_graphing(relation, sorting_direction, number_of_elements)
    relation
      .order(lesson_date: sorting_direction).limit(number_of_elements)
      .select(Arel.sql('extract(EPOCH FROM lesson_date) :: INT AS timestamp'), :average_mark, Arel.sql("to_char(lesson_date, 'MM/DD/YY') AS date"), :lesson_uid, :lesson_id)
  end

  def process_around_result(result, number_of_elements)
    index = result.index { |l| l.lesson_uid == lesson_uid }
    number_of_elements = [result.size, number_of_elements].min
    result[
      [[index - (number_of_elements / 2), 0].max, result.size - number_of_elements].min,
      number_of_elements
    ]
  end
end
