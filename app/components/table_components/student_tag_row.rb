# frozen_string_literal: true

class TableComponents::StudentTagRow < TableComponents::BaseRow
  def self.columns
    [
      { column_name: '#', numeric: true },
      { order_key: :tag_name, column_name: I18n.t(:tag_name) },
      { order_key: :organization_name, column_name: I18n.t(:organization) },
      { order_key: :student_count, column_name: I18n.t(:number_of_students), numeric: true },
      { column_name: I18n.t(:actions) }
    ]
  end
end
