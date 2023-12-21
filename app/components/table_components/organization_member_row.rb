# frozen_string_literal: true

class TableComponents::OrganizationMemberRow < TableComponents::BaseRow
  erb_template <<~ERB
    <div class="<%= 'shaded-row' if shaded? %> table-row-wrapper chapter-row">
      <a href="<%= helpers.user_path @item %>" class="<%= 'shaded-row' if shaded? %> table-row-wrapper">
        <div class="table-cell "><%= @pagy.from + @item_counter %></div>
        <div class="text-right table-cell "><%= @item.name %></div>
        <div class="text-right table-cell "><%= @item.email %></div>
        <div class="text-right table-cell "><%= t(@item.local_role.to_sym) %></div>
        <div class="text-right table-cell "><%= t(@item.global_role.try(:to_sym)) %></div>
      </a>
    </div>
  ERB

  def self.columns
    [
      { column_name: '#', numeric: true },
      { order_key: :name, column_name: I18n.t(:name) },
      { order_key: :email, column_name: I18n.t(:email) },
      { column_name: I18n.t(:role) },
      { column_name: I18n.t(:global_role) }
    ]
  end
end
