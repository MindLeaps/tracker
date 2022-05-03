# frozen_string_literal: true

class TableComponents::LessonRow < TableComponents::BaseRow
  def self.columns
    [
      { column_name: '#', numeric: true },
      { column_name: I18n.t(:group_chapter) },
      { order_key: :date, column_name: I18n.t(:lesson_date), numeric: true },
      { column_name: I18n.t(:subject) },
      { column_name: I18n.t(:graded_vs_students_in_group), numeric: true },
      { column_name: I18n.t(:average_grade), numeric: true }
    ]
  end
end
