# frozen_string_literal: true

class TableComponents::StudentLessonRow < TableComponents::BaseRow
  def self.columns
    [
      { column_name: '#', numeric: true },
      { order_key: :last_name, column_name: I18n.t(:last_name) },
      { order_key: :first_name, column_name: I18n.t(:first_name) },
      { order_key: :graded_skills, column_name: I18n.t(:graded_of_skills) },
      { order_key: :average, column_name: I18n.t(:average) }
    ]
  end

  def fully_graded?
    @item.grade_count == @item.skill_count
  end

  def ungraded?
    @item.grade_count.zero?
  end
end
