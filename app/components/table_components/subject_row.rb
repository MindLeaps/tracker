# frozen_string_literal: true

class TableComponents::SubjectRow < TableComponents::BaseRow
  def self.columns
    [
      { column_name: '#', numeric: true },
      { column_name: I18n.t(:subject_name) },
      { column_name: I18n.t(:organization) },
      { column_name: I18n.t(:skills), numeric: true }
    ]
  end
end
