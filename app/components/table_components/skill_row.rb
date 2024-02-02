# frozen_string_literal: true

class TableComponents::SkillRow < TableComponents::BaseRow
  def self.columns
    [
      { column_name: '#', numeric: true },
      { order_key: :skill_name, column_name: I18n.t(:skill_name) },
      { order_key: :'organizations.organization_name', column_name: I18n.t(:organization) },
      { order_key: :created_at, column_name: I18n.t(:created), numeric: true }
    ]
  end
end
