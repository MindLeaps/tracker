class TableComponents::BulkTagStudentRow < TableComponents::BaseRow
  erb_template <<~ERB
    <%= hidden_field_tag "students[#{@item_counter}][id]", @item.id %>
    <div class="<%= 'shaded-row' if shaded? %> table-row-wrapper student-row">
      <div class="table-cell flex! items-center "><%= @item.first_name %></div>
      <div class="table-cell flex! items-center "><%= @item.last_name %></div>
      <div class="text-right table-cell flex! items-center "><% @item.tags.each do |tag| %><span class="mdl-chip"><span class="mdl-chip__text"><%= tag.tag_name %> </span></span><% end %></div>
      <div class="table-cell flex! items-center ">
        <%= check_box_tag "students[#{@item_counter}][to_tag]", class: 'h-5 w-5 border-purple-500 focus:ring-green-600 cursor-pointer', checked: false %>
      </div>
    </div>
  ERB

  def self.columns
    [
      { column_name: I18n.t(:first_name) },
      { column_name: I18n.t(:last_name) },
      { column_name: I18n.t(:tags) },
      { column_name: I18n.t(:assign) }
    ]
  end
end
