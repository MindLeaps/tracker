# frozen_string_literal: true

class TableComponents::UserRow < TableComponents::BaseRow
  def self.columns
    [
      { column_name: '#', numeric: true },
      { order_key: :name, column_name: I18n.t(:name) },
      { order_key: :email, column_name: I18n.t(:email) },
      { column_name: I18n.t(:global_role) }
    ]
  end

  def global_role
    @item.global_role? ? @item.global_role.label : I18n.t(:none)
  end
end
