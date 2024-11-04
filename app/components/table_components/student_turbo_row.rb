class TableComponents::StudentTurboRow < TableComponents::BaseRow
  def self.columns
    [
      { column_name: '#', numeric: true },
      { order_key: :full_mlid, column_name: I18n.t(:mlid), numeric: true },
      { order_key: :last_name, column_name: I18n.t(:last_name) },
      { order_key: :first_name, column_name: I18n.t(:first_name) },
      { order_key: :gender, column_name: I18n.t(:gender) },
      { order_key: :dob, column_name: I18n.t(:date_of_birth), numeric: true },
      { order_key: :created_at, column_name: I18n.t(:created), numeric: true },
      { column_name: I18n.t(:actions) }
    ]
  end
end
