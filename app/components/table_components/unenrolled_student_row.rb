class TableComponents::UnenrolledStudentRow < TableComponents::BaseRow
  erb_template <<~ERB
    <div class="<%= 'shaded-row' if shaded? %> table-row-wrapper student-row">
      <div class="text-right table-cell "> <%= "students[0][:first_name]" %> </div>
      <div class="text-right table-cell "><%= @item[:last_name] %></div>
      <div class="text-right table-cell ">
        <%= check_box_tag @item[:to_enroll], class: 'h-4 w-4 ml-4 border-purple-500 focus:ring-green-600 cursor-pointer', checked: false %>
      </div>
      <div class="table-cell ">
        <%= render Datepicker.new(date: Date.current, target: 'enrollment_start_date', custom_name: 'enrollment_start_date') %>
      </div>
    </div>
  ERB

  def self.columns
    [
      { order_key: :first_name, column_name: I18n.t(:first_name) },
      { order_key: :last_name, column_name: I18n.t(:last_name) },
      { order_key: :first_lesson, column_name: 'Enroll' },
      { order_key: :middle_lesson, column_name: 'Enrolled Since' }
    ]
  end
end
