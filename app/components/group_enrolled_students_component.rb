class GroupEnrolledStudentsComponent < ViewComponent::Base
  include Pagy::Backend

  erb_template <<~ERB
    <%= render CommonComponents::Card.new(title: t(:students_in_group).capitalize) do |card| %>
      <% card.with_card_content do %>
        <%= render StudentTableForm.new(student: @new_student, group: @group, is_edit: false) if helpers.policy(@new_student).create? %>
        <%= render TableComponents::Table.new(pagy: @pagy, options: { no_pagination: true, turbo_id: 'students' }, rows: @students, row_component: TableComponents::StudentTurboRow, row_arguments: { group: @group }) %>
      <% end %>
    <% end %>
  ERB

  def initialize(students:, group:)
    @student_records = students
    @group = group
    @new_student = Student.new
    @new_student.enrollments.build(group: @group)
  end

  def before_render
    @pagy, @students = pagy @student_records
  end
end
