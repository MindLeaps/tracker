class StudentTableForm < ViewComponent::Base
  erb_template <<~ERB
    <%= form_with url: url, model: @student, id: dom_id(@student), class: form_class do |form| %>
      <div class="table-cell" data-controller="mlid">
        <input type="text" class="hidden" value="<%= @student.group_id %>" data-mlid-target="group" />
        <%= render CommonComponents::StudentMlidInput.new(@student.mlid) %>
        <%= render ValidationErrorComponent.new(model: @student, key: :mlid) %>
      </div>
      <div class="table-cell text-right">
        <%= form.text_field :last_name, class: "w-full rounded-md border-purple-500 shadow-sm focus:border-green-600 focus:ring-green-600 sm:text-sm" %>
        <%= render ValidationErrorComponent.new(model: @student, key: :last_name) %>
      </div>
      <div class="table-cell text-right">
        <%= form.text_field :first_name, class: "w-full rounded-md border-purple-500 shadow-sm focus:border-green-600 focus:ring-green-600 sm:text-sm" %>
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
      <div class="table-cell flex justify-start gap-4 items-center">
        <%= render Datepicker.new(date: @student.dob || Date.new(Date.current.year, 1, 1), target: 'dob', form: form) %>
        <%= form.check_box :estimated_dob, checked: @student.estimated_dob , class: 'h-4 w-4 border-purple-500 text-green-600 focus:ring-green-600 cursor-pointer ml-1' %>
        <label class="text-xs font-medium text-gray-700 cursor-pointer"><%= t(:dob_estimated) %></label>
        <%= render ValidationErrorComponent.new(model: @student, key: :dob) %>
      </div>
      <div class="table-cell"></div>
      <div class="table-cell">
        <%= form.submit class: "px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500 cursor-pointer" %>
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
  end

  def url
    @is_edit ? group_student_path(@group, @student) : group_students_path(@group, @student)
  end

  def form_class
    if @is_edit
      'table-row-wrapper student-row'
    else
      'w-full flex items-center justify-between bg-gray-50 border-b border-gray-200'
    end
  end
end
