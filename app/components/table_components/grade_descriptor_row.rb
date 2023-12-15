# frozen_string_literal: true

class TableComponents::GradeDescriptorRow < TableComponents::BaseRow
  def self.columns
    [
      { order_key: :group_name, column_name: I18n.t(:mark), numeric: true },
      { order_key: :chapter_name, column_name: I18n.t(:grade_description) }
    ]
  end
end
