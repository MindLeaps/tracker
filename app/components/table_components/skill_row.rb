# frozen_string_literal: true

class TableComponents::SkillRow < TableComponents::BaseRow
  def self.columns
    [
      { column_name: '#', numeric: true },
      { column_name: I18n.t(:skill_name) },
      { column_name: I18n.t(:organization) },
      { order_key: :created_at, column_name: I18n.t(:created), numeric: true }
    ]
  end
end
