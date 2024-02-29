class TableComponents::ChapterRow < TableComponents::BaseRow
  erb_template <<~ERB
    <div class="<%= 'shaded-row' if shaded? %> <%= 'deleted-row' if @item.deleted_at? %> table-row-wrapper chapter-row">
      <a href="<%= helpers.chapter_path @item %>" class="<%= 'shaded-row' if shaded? %> <%= 'deleted-row' if @item.deleted_at? %> table-row-wrapper">
        <div class="table-cell "><%= @pagy.from + @item_counter %></div>
        <div class="table-cell "><span class="faded"><%= "\#{@item.organization_mlid}-" %></span><%= @item.chapter_mlid %></div>
        <div class="text-right table-cell "><%= @item.chapter_name %></div>
        <div class="text-right table-cell "><%= @item.organization_name %></div>
        <div class="table-cell "><%= @item.group_count %></div>
        <div class="table-cell "><%= @item.student_count %></div>
        <div class="table-cell "><%= @item.created_at.strftime('%F') %></div>
        <div class="text-right table-cell ">
          <% if can_update? %>
            <a id="edit-button-<%= @group_counter %>" class="table-action-link" href="<%= helpers.edit_chapter_path @item %>"><%= t(:edit) %></a>
          <% end %>
        </div>
      </a>
    </div>
  ERB
  def self.columns
    [
      { column_name: '#', numeric: true },
      { order_key: :full_mlid, column_name: I18n.t(:mlid), numeric: true },
      { order_key: :chapter_name, column_name: I18n.t(:chapter) },
      { order_key: :organization_name, column_name: I18n.t(:organization) },
      { order_key: :group_count, column_name: I18n.t(:number_of_groups), numeric: true },
      { order_key: :student_count, column_name: I18n.t(:number_of_students), numeric: true },
      { order_key: :created_at, column_name: I18n.t(:created), numeric: true },
      { column_name: I18n.t(:actions) }
    ]
  end
end
