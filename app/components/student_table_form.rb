class StudentTableForm < ViewComponent::Base
  erb_template <<~ERB
    <%= form_with url: url, model: @student, id: dom_id(@student), class: form_class do |form| %>
        <% unless @is_edit%>
          <% { t(:mlid) => true, t(:last_name) => false, t(:first_name) => false, t(:gender) => false, t(:date_of_birth) => true, t(:enrolled_since) => true, 'Submit' => false }.each do |name, numeric| %>
            <%= render TableComponents::UnorderedColumn.new(column: { column_name: name, numeric: numeric }) %>
          <% end %>
        <% end %>
        <div class="table-cell" data-controller="mlid" data-mlid-student-id-value="<%= @student.id %>">
          <input type="text" class="hidden" value="<%= @student.organization_id || @group.chapter.organization.id %>" data-mlid-target="organization" />
          <%= render CommonComponents::StudentMlidInput.new(@student.mlid, student_id: @student.id) %>
          <%= render ValidationErrorComponent.new(model: @student, key: :mlid) %>
        </div>
        <div class="table-cell text-right">
          <%= form.text_field :last_name, class: "w-full rounded-md border-purple-500 shadow-xs focus:border-green-600 focus:ring-green-600 sm:text-sm" %>
          <%= render ValidationErrorComponent.new(model: @student, key: :last_name) %>
        </div>
        <div class="table-cell text-right">
          <%= form.text_field :first_name, class: "w-full rounded-md border-purple-500 shadow-xs focus:border-green-600 focus:ring-green-600 sm:text-sm" %>
          <%= render ValidationErrorComponent.new(model: @student, key: :first_name) %>
        </div>
        <div class="table-cell text-right">
          <div class="inline-flex items-center h-full">
            <%= form.radio_button :gender, :M, class: 'h-4 w-4 border-purple-500 text-green-600 focus:ring-green-600 cursor-pointer', checked: @student.gender == 'M' || @student.gender.nil? %>
            <label class="ml-1 text-sm font-medium text-gray-700 cursor-pointer"><%= t(:enums)[:student][:gender][:M] %></label>
          </div>
          <div class="inline-flex items-center h-full">
            <%= form.radio_button :gender, :F, class: 'h-4 w-4 border-purple-500 text-green-600 focus:ring-green-600 cursor-pointer', checked: @student.gender == 'F' %>
            <label class="ml-1 text-sm font-medium text-gray-700 cursor-pointer"><%= t(:enums)[:student][:gender][:F] %></label>
          </div>
          <div class="inline-flex items-center h-full">
            <%= form.radio_button :gender, :NB, class: 'h-4 w-4 border-purple-500 text-green-600 focus:ring-green-600 cursor-pointer', checked: @student.gender == 'NB' %>
            <label class="ml-1 text-sm font-medium text-gray-700 cursor-pointer"><%= t(:enums)[:student][:gender][:NB] %></label>
          </div>
        </div>
        <div class="table-cell flex justify-start gap-2 items-center">
          <%= render Datepicker.new(date: @student.dob || Date.current, target: 'dob', form: form) %>
          <%= form.check_box :estimated_dob, checked: @student.estimated_dob , class: 'h-4 w-4 border-purple-500 text-green-600 focus:ring-green-600 cursor-pointer ml-1' %>
          <label class="text-xs font-medium text-gray-700 cursor-pointer"><%= t(:dob_estimated) %></label>
          <%= render ValidationErrorComponent.new(model: @student, key: :dob) %>
        </div>
        <div class="table-cell">
          <% if @is_edit %>
            <%= hidden_field_tag sprintf("student[enrollments_attributes][%d][id]", @enrollment_index), @active_enrollment.id %>
            <%= render Datepicker.new(date: @active_enrollment.active_since, target: :active_since, custom_name: sprintf("student[enrollments_attributes][%d][active_since]", @enrollment_index)) %>
            <%= render ValidationErrorComponent.new(model: @student, key: 'enrollments.active_since') %>
          <% else %>
            <%= render Datepicker.new(date: Date.current, target: 'enrollment_start_date', form: form) %>
            <%= render ValidationErrorComponent.new(model: @student, key: 'enrollments.active_since') %>
          <% end %>
        </div>
        <div class="table-cell text-right">
          <%= form.submit class: "px-4 py-2 border border-transparent shadow-xs text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-hidden focus:ring-2 focus:ring-offset-2 focus:ring-purple-500 cursor-pointer" %>
          <% if @is_edit %>
            <%= link_to t(:cancel), cancel_edit_group_student_path(@group.id, @student.id), data: { "turbo-method": "post", "turbo-stream": "" } %>
          <% end %>
        </div>
    <% end %>
  ERB

  def initialize(student:, group:, is_edit: false)
    @student = student
    @group = group
    @organization = group.chapter.organization
    @is_edit = is_edit
    @student.mlid = MindleapsIdService.generate_student_mlid @organization.id unless @is_edit
    @lesson_dates = @group.lessons.map(&:date).sort.last(10).reverse

    # needed when editing a student directly
    @active_enrollment = @student.latest_enrollment_for_group(@group)
    @enrollment_index = @student.enrollments.index(@active_enrollment) || 0
  end

  def url
    @is_edit ? helpers.group_student_path(@group.id, @student.id) : helpers.group_students_path(@group.id, @student.id)
  end

  def form_class
    if @is_edit
      'table-row-wrapper student-row'
    else
      'w-full bg-gray-50 border-b border-gray-200 grid grid-cols-7 justify-between'
    end
  end
end
