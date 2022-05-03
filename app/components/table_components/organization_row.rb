# frozen_string_literal: true

class TableComponents::OrganizationRow < TableComponents::BaseRow
  def self.columns
    [
      { column_name: '#', numeric: true },
      { order_key: :mlid, column_name: I18n.t(:mlid), numeric: true },
      { order_key: :organization_name, column_name: I18n.t(:chapter) },
      { order_key: :chapter_count, column_name: I18n.t(:number_of_chapters), numeric: true },
      { order_key: :group_count, column_name: I18n.t(:number_of_groups), numeric: true },
      { order_key: :student_count, column_name: I18n.t(:number_of_students), numeric: true },
      { column_name: I18n.t(:actions) }
    ]
  end
end

