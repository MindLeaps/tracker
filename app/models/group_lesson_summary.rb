# frozen_string_literal: true

class GroupLessonSummary < ApplicationRecord
  self.primary_key = :lesson_uid
  belongs_to :chapter

  def readonly?
    true
  end

  def around(number_of_elements)
    before = GroupLessonSummary
               .where('lesson_date <= ? AND group_id = ?', lesson_date, group_id)
               .order(lesson_date: :desc).limit(number_of_elements)
               .pluck(Arel.sql('extract(EPOCH FROM lesson_date) :: INT'), :average_mark, Arel.sql("to_char(lesson_date, 'MM/DD/YY')"), :lesson_uid, :lesson_id)
    after = GroupLessonSummary
              .where('lesson_date > ? AND group_id = ?', lesson_date, group_id)
              .order(:lesson_date).limit(number_of_elements)
              .pluck(Arel.sql('extract(EPOCH FROM lesson_date) :: INT'), :average_mark, Arel.sql("to_char(lesson_date, 'MM/DD/YY')"), :lesson_uid, :lesson_id)
    result = before.reverse + after
    index = result.index { |l| l[3] == lesson_uid }
    number_of_elements = [result.size, number_of_elements].min
    result[
      [[index - (number_of_elements / 2), 0].max, result.size - number_of_elements].min,
      number_of_elements
    ]
  end
end
