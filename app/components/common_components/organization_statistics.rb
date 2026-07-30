class CommonComponents::OrganizationStatistics < ViewComponent::Base
  include ApplicationHelper
  include CollectionHelper

  def initialize(group_lesson_summaries, selected_date:, available_lesson_dates: [], used_default_date: false)
    @lesson_summaries = group_lesson_summaries
    @selected_date = selected_date
    @available_lesson_dates = available_lesson_dates
    @used_default_date = used_default_date
    @number_of_lessons = @lesson_summaries.count
    @total_data_points = @lesson_summaries.sum(&:grade_count)
  end

  erb_template <<~ERB
    <div>
      <div class="flex align-center justify-between w-full p-2">
        <div>
          <%= render Datepicker.new(date: @selected_date, target: 'selected_date', enabled_dates: @available_lesson_dates.map(&:to_s)) do |picker| %>
            <% picker.with_input_field do %>
              <input id="select_date" data-datepicker-target="picker" value="<%= @selected_date %>"  class="mt-1 rounded-md border-purple-500 text-sm focus:border-green-600 focus:outline-hidden focus:ring-green-600"
               data-action="change->datepicker#updateFilter"/>
              <%= render CommonComponents::ButtonComponent.new(label: t(:filter), options: { 'data-datepicker-target' => 'anchor' })%>
            <% end %>
          <% end %>
          <% if @used_default_date && @available_lesson_dates.any? %>
            <p class="text-xs text-gray-500 mt-1"><%= t(:showing_data_for_last_lessons) %></p>
          <% end %>
        </div>
      </div>
      <% if @lesson_summaries.any? %>
        <dl class="mt-6 grid grid-cols-2 gap-5 sm:grid-cols-2">
        <div class="overflow-hidden rounded-lg bg-white px-4 py-5 shadow-lg sm:p-6">
          <dt class="truncate text-sm font-medium text-gray-500"><%= t(:nr_of_lessons) %></dt>
          <dd class="mt-1 text-3xl font-semibold tracking-tight text-gray-900"><%= @number_of_lessons %></dd>
        </div>
        <div class="overflow-hidden rounded-lg bg-white px-4 py-5 shadow-lg sm:p-6">
          <dt class="truncate text-sm font-medium text-gray-500"><%= t(:nr_of_assessments) %></dt>
          <dd class="mt-1 text-3xl font-semibold tracking-tight text-gray-900"><%= @total_data_points %></dd>
        </div>
        </dl>
        <dl class="mt-2">
          <div class="overflow-hidden rounded-lg bg-white px-4 py-5 shadow-lg sm:p-6">
            <dt class="truncate text-sm font-medium text-gray-500"><%= t(:groups_with_lessons) %></dt>
            <% @lesson_summaries.map(&:group_chapter_name).sort.each do |summary| %>
              <dd class="mt-1 text-lg font-semibold tracking-tight text-gray-900"><%= summary %></dd>
            <% end %>
          </div>
        </dl>
      <% else %>
        <h1 class="text-center text-xxl font-bold text-gray-500"> <%= t(:no_lessons_data_exists) %> </h1>
      <% end %>
    </div>
  ERB
end
