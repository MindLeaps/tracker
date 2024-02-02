# frozen_string_literal: true

class TableComponents::SubjectRow < TableComponents::BaseRow
  def self.columns
    [
      { column_name: '#', numeric: true },
      { order_key: :subject_name, column_name: I18n.t(:subject_name) },
      { order_key: :'organizations.organization_name', column_name: I18n.t(:organization) },
      { order_key: :'skills.count', column_name: I18n.t(:skills), numeric: true },
      { order_key: :created_at, column_name: I18n.t(:created), numeric: true }
    ]
  end
end
