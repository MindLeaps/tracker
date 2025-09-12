class TableComponents::UnenrolledStudentRow < TableComponents::BaseRow
  erb_template <<~ERB
    <%= hidden_field_tag "students[#{@item_counter}][id]", @item.id %>
    <div class="<%= 'shaded-row' if shaded? %> table-row-wrapper student-row">
      <div name="students[#{@item_counter}][first_name]" class="table-cell flex! items-center justify-end "> <%= @item[:first_name] %> </div>
      <div name="students[#{@item_counter}][first_name]" class="table-cell flex! items-center justify-end "><%= @item[:last_name] %></div>
      <div class="table-cell flex! items-center justify-end ">
        <%= check_box_tag name="students[#{@item_counter}][to_enroll]", class: 'h-4 w-4 ml-4 border-purple-500 focus:ring-green-600 cursor-pointer', checked: false %>
      </div>
      <div class="table-cell ">
        <%= render Datepicker.new(date: Date.current, target: 'enrollment_start_date', custom_name: name="students[#{@item_counter}][enrollment_start_date]") %>
      </div>
    </div>
  ERB

  def self.columns
    [
      { order_key: :first_name, column_name: I18n.t(:first_name), },
      { order_key: :last_name, column_name: I18n.t(:last_name) },
      { order_key: :first_lesson, column_name: 'Enroll' },
      { order_key: :middle_lesson, column_name: 'Enrolled Since' }
    ]
  end
end
