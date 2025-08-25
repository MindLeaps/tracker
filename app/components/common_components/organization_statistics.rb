class CommonComponents::OrganizationStatistics < ViewComponent::Base
  include ApplicationHelper
  include CollectionHelper

  def initialize(group_lesson_summaries, selected_date = Time.zone.today)
    @lesson_summaries = group_lesson_summaries
    @selected_date = selected_date
    @number_of_lessons = @lesson_summaries.count
    @total_data_points = @lesson_summaries.sum(&:grade_count)
    @sum_of_average_marks = @lesson_summaries.where.not(average_mark: nil).sum(:average_mark)
    @average_mark_across_groups = @lesson_summaries.any? ? (@sum_of_average_marks / @lesson_summaries.count.to_f).round(2) : 0
    @average_attendance_across_groups = average_from_array(@lesson_summaries.map(&:attendance)).round(2)
  end

  erb_template <<~ERB
    <div>
      <div class="flex align-center justify-between w-full p-2">
        <%= render Datepicker.new(date: @selected_date, target: 'selected_date') do |picker| %>
          <% picker.with_input_field do %>
            <input data-datepicker-target="picker" value="<%= @selected_date %>"  class="mt-1 rounded-md border-purple-500 text-sm focus:border-green-600 focus:outline-hidden focus:ring-green-600" 
             data-action="change->datepicker#updateFilter"/>
            <%= render CommonComponents::ButtonComponent.new(label: t(:filter), options: { 'data-datepicker-target' => 'anchor' })%>
          <% end %>
        <% end %>
      </div>
      <% if @lesson_summaries.any? %>
        <dl class="mt-14 grid grid-cols-2 gap-5 sm:grid-cols-2">
        <div class="overflow-hidden rounded-lg bg-white px-4 py-5 shadow-lg sm:p-6">
          <dt class="truncate text-sm font-medium text-gray-500"><%= t(:nr_of_lessons) %></dt>
          <dd class="mt-1 text-3xl font-semibold tracking-tight text-gray-900"><%= @number_of_lessons %></dd>
        </div>
        <div class="overflow-hidden rounded-lg bg-white px-4 py-5 shadow-lg sm:p-6">
          <dt class="truncate text-sm font-medium text-gray-500"><%= t(:nr_of_assessments) %></dt>
          <dd class="mt-1 text-3xl font-semibold tracking-tight text-gray-900"><%= @total_data_points %></dd>
        </div>
        <div class="overflow-hidden rounded-lg bg-white px-4 py-5 shadow-lg sm:p-6">
          <dt class="truncate text-sm font-medium text-gray-500"><%= t(:average_mark_across_groups) %></dt>
          <dd class="mt-1 text-3xl font-semibold tracking-tight text-gray-900"><%= @average_mark_across_groups %></dd>
        </div>
        <div class="overflow-hidden rounded-lg bg-white px-4 py-5 shadow-lg sm:p-6">
          <dt class="truncate text-sm font-medium text-gray-500"><%= t(:average_attendance_across_groups) %></dt>
          <dd class="mt-1 text-3xl font-semibold tracking-tight text-gray-900"><%= @average_attendance_across_groups %>%</dd>
        </div>
        </dl>
      <% else %>
        <h1 class="text-center text-xxl font-bold text-gray-500"> No data for the selected date </h1>
      <% end %>
    </div>
  ERB
end
