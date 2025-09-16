class TableComponents::UnenrolledStudentRow < TableComponents::BaseRow
  erb_template <<~ERB
    <% if @pass_id %>
      <%= hidden_field_tag "students[#{@item_counter}][id]", @item.id %>
    <% end %>
    <div class="<%= 'shaded-row' if shaded? %> table-row-wrapper student-row">
      <div class="table-cell flex! items-center "> <%= @item[:first_name] %> </div>
      <div class="table-cell flex! items-center "><%= @item[:last_name] %></div>
      <div class="table-cell flex! items-center ">
        <%= check_box_tag name="students[#{@item_counter}][to_enroll]", class: 'h-5 w-5 border-purple-500 focus:ring-green-600 cursor-pointer', checked: false %>
      </div>
      <div class="table-cell ">
        <%= render Datepicker.new(date: Date.current, target: 'enrollment_start_date', custom_name: name="students[#{@item_counter}][enrollment_start_date]") %>
      </div>
    </div>
  ERB

  def self.columns
    [
      { order_key: :first_name, column_name: I18n.t(:first_name) },
      { order_key: :last_name, column_name: I18n.t(:last_name) },
      { order_key: :dob, column_name: I18n.t(:enroll) },
      { order_key: :created_at, column_name: I18n.t(:enrolled_since), numeric: true }
    ]
  end

  def initialize(item:, item_counter:, pagy:, pass_id: false)
    super(item: item, item_counter: item_counter, pagy: pagy)
    @pass_id = pass_id
  end
end
