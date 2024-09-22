class TableComponents::StudentEnrollmentReport < TableComponents::BaseRow
  erb_template <<~ERB
    <div class="<%= 'shaded-row' if shaded? %> table-row-wrapper student-row">
        <div class="text-right table-cell "><%= @item[:mlid] %></div>
        <div class="text-right table-cell "><%= @item[:full_name] %></div>
        <div class="text-right table-cell "><%= @item[:gender] %></div>
        <div class="text-right table-cell "><%= @item[:dob] %></div>
        <div class="text-right table-cell "><%= @item[:join_date] %></div>
        <div class="text-right table-cell "><%= @item[:leave_date] || '' %></div>
    </div>
  ERB

  def self.columns
    [
      { order_key: :mlid, column_name: I18n.t(:mlid) },
      { order_key: :full_name, column_name: I18n.t(:full_name) },
      { order_key: :gender, column_name: I18n.t(:gender) },
      { order_key: :dob, column_name: I18n.t(:date_of_birth) },
      { order_key: :join_date, column_name: I18n.t(:join_date) },
      { order_key: :leave_date, column_name: I18n.t(:leave_date) }
    ]
  end
end
