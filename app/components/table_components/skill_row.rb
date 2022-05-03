# frozen_string_literal: true

class TableComponents::SkillRow < TableComponents::BaseRow
  def self.columns
    [
      { column_name: '#', numeric: true },
      { column_name: I18n.t(:skill_name) },
      { column_name: I18n.t(:organization) },
    ]
  end
end
