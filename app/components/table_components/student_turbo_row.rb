class TableComponents::StudentTurboRow < TableComponents::BaseRow
  def self.columns
    [
      { order_key: :mlid, column_name: I18n.t(:mlid), numeric: true },
      { order_key: :last_name, column_name: I18n.t(:last_name) },
      { order_key: :first_name, column_name: I18n.t(:first_name) },
      { order_key: :gender, column_name: I18n.t(:gender) },
      { order_key: :dob, column_name: I18n.t(:date_of_birth), numeric: true },
      { order_key: :enrolled_since, column_name: I18n.t(:enrolled_since), numeric: true },
      { column_name: I18n.t(:actions) }
    ]
  end

  def self.row_style
    "grid-template-columns: repeat(#{TableComponents::StudentTurboRow.columns.count}, auto);"
  end

  def initialize(item:, item_counter:, pagy:, group:)
    super(item: item, item_counter: item_counter, pagy: pagy)
    @group = group
  end
end
