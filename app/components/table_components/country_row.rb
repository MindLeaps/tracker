class TableComponents::CountryRow < TableComponents::BaseRow
  def self.columns
    [
      { column_name: '#', numeric: true },
      { order_key: :country_name, column_name: I18n.t(:country_name) },
      { order_key: :organization_count, column_name: I18n.t(:number_of_organizations), numeric: true },
      { column_name: I18n.t(:actions) }
    ]
  end
end
