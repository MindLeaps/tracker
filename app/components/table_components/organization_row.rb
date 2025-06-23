class TableComponents::OrganizationRow < TableComponents::BaseRow
  erb_template <<~ERB
    <div class="<%= 'shaded-row' if shaded? %> <%= 'deleted-row' if @item.deleted_at? %> table-row-wrapper organization-row">
      <a href="<%= helpers.organization_path @item %>" class="<%= 'shaded-row' if shaded? %> <%= 'deleted-row' if @item.deleted_at? %> table-row-wrapper">
        <div class="table-cell "><%= @pagy.from + @item_counter %></div>
        <div class="table-cell "></span><%= @item.organization_mlid %></div>
        <div class="text-right table-cell truncate"><%= @item.organization_name %></div>
        <div class="table-cell "><%= @item.chapter_count %></div>
        <div class="table-cell "><%= @item.group_count %></div>
        <div class="table-cell "><%= @item.student_count %></div>
        <div class="table-cell truncate"><%= @item.country_name %></div>
        <div class="table-cell "><%= @item.created_at.strftime('%F') %></div>
        <div class="text-right table-cell ">
          <% if can_update? %>
            <a id="edit-button-<%= @item_counter %>" class="table-action-link" href="<%= helpers.edit_organization_path(@item) %>"><%= t(:edit) %></a>
          <% end %>
        </div>
      </a>
    </div>
  ERB
  def self.columns
    [
      { column_name: '#', numeric: true },
      { order_key: :mlid, column_name: I18n.t(:mlid), numeric: true },
      { order_key: :organization_name, column_name: I18n.t(:organization) },
      { order_key: :chapter_count, column_name: I18n.t(:number_of_chapters), numeric: true },
      { order_key: :group_count, column_name: I18n.t(:number_of_groups), numeric: true },
      { order_key: :student_count, column_name: I18n.t(:number_of_students), numeric: true },
      { order_key: :country_name, column_name: I18n.t(:country), numeric: true },
      { order_key: :created_at, column_name: I18n.t(:created), numeric: true },
      { column_name: I18n.t(:actions) }
    ]
  end
end
