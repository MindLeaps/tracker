class TableComponents::StudentRow < TableComponents::BaseRow
  erb_template <<~ERB
    <div class="<%= 'shaded-row' if shaded? %> <%= 'deleted-row' if @item.deleted_at? %> table-row-wrapper student-row">
      <a target="_top" href="<%= helpers.student_path @item %>" class="<%= 'shaded-row' if shaded? %> <%= 'deleted-row' if @item.deleted_at? %> table-row-wrapper">
        <div class="table-cell "><%= @pagy.from + @item_counter %></div>
        <div class="table-cell "></span><%= @item.mlid %></div>
        <div class="text-right table-cell "><%= @item.last_name %></div>
        <div class="text-right table-cell "><%= @item.first_name %></div>
        <div class="text-right table-cell "><%= @item.gender %></div>
        <div class="table-cell "><%= "\#{@item.estimated_dob ? t(:circa) : ''}\#{@item.dob}" %></div>
        <div class="text-right table-cell "><% @item.tags.each do |tag|%><span class="mdl-chip"><span class="mdl-chip__text"><%= tag.tag_name %> </span></span><% end %></div>
        <div class="text-right table-cell "><%= @item.organization.organization_name %></div>
        <div class="table-cell "><%= @item.created_at.strftime('%F') %></div>
        <div class="text-right table-cell ">
          <% if can_update? %>
            <a id="edit-button-<%= @item_counter %>" class="table-action-link" href="<%= helpers.edit_student_path(@item) %>"><%= t(:edit) %></a>
          <% end %>
        </div>
      </a>
    </div>
  ERB

  def self.columns
    [
      { column_name: '#', numeric: true },
      { order_key: :mlid, column_name: I18n.t(:mlid), numeric: true },
      { order_key: :last_name, column_name: I18n.t(:last_name) },
      { order_key: :first_name, column_name: I18n.t(:first_name) },
      { order_key: :gender, column_name: I18n.t(:gender) },
      { order_key: :dob, column_name: I18n.t(:date_of_birth), numeric: true },
      { column_name: I18n.t(:tags) },
      { order_key: :organization_id, column_name: I18n.t(:organization) },
      { order_key: :created_at, column_name: I18n.t(:created), numeric: true },
      { column_name: I18n.t(:actions) }
    ]
  end
end
