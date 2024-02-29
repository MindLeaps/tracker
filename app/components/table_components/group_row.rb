class TableComponents::GroupRow < TableComponents::BaseRow
  def self.columns
    [
      { column_name: '#', numeric: true },
      { order_key: :full_mlid, column_name: I18n.t(:mlid), numeric: true },
      { order_key: :group_name, column_name: I18n.t(:group_name) },
      { order_key: :chapter_name, column_name: I18n.t(:chapter_organization) },
      { order_key: :student_count, column_name: I18n.t(:number_of_students), numeric: true },
      { order_key: :created_at, column_name: I18n.t(:created), numeric: true },
      { column_name: I18n.t(:actions) }
    ]
  end
end
