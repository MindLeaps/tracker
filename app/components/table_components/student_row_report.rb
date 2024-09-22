class TableComponents::StudentRowReport < TableComponents::BaseRow
  erb_template <<~ERB
    <div class="<%= 'shaded-row' if shaded? %> table-row-wrapper student-row">
        <div class="text-right table-cell "><%= @item[:first_name] %></div>
        <div class="text-right table-cell "><%= @item[:last_name] %></div>
        <div class="text-right table-cell "><%= @item[:first_lesson] %></div>
        <div class="text-right table-cell "><%= @item[:middle_lesson] %></div>
        <div class="text-right table-cell "><%= @item[:last_lesson] %></div>
    </div>
  ERB

  def self.columns
    [
      { order_key: :first_name, column_name: I18n.t(:first_name) },
      { order_key: :last_name, column_name: I18n.t(:last_name) },
      { order_key: :first_lesson, column_name: I18n.t(:first_lesson) },
      { order_key: :middle_lesson, column_name: I18n.t(:middle_lesson) },
      { order_key: :last_lesson, column_name: I18n.t(:last_lesson) }
    ]
  end
end
