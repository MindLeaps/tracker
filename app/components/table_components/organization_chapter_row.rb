# frozen_string_literal: true

class TableComponents::OrganizationChapterRow < TableComponents::BaseRow
  erb_template <<~ERB
    <div class="<%= 'shaded-row' if shaded? %> <%= 'deleted-row' if @item.deleted_at? %> table-row-wrapper chapter-row">
      <a href="<%= helpers.chapter_path @item %>" class="<%= 'shaded-row' if shaded? %> <%= 'deleted-row' if @item.deleted_at? %> table-row-wrapper">
        <div class="table-cell "><%= @pagy.from + @item_counter %></div>
        <div class="table-cell "><span class="faded"><%= @item.organization_mlid %>-</span><%= @item.chapter_mlid %></div>
        <div class="text-right table-cell "><%= @item.chapter_name %></div>
        <div class="table-cell "><%= @item.group_count %></div>
        <div class="table-cell "><%= @item.student_count %></div>
      </a>
    </div>
  ERB

  def self.columns
    [
      { column_name: '#', numeric: true },
      { order_key: :full_mlid, column_name: I18n.t(:mlid), numeric: true },
      { order_key: :chapter_name, column_name: I18n.t(:chapter) },
      { order_key: :group_count, column_name: I18n.t(:number_of_groups), numeric: true },
      { order_key: :student_count, column_name: I18n.t(:number_of_students), numeric: true }
    ]
  end
end
