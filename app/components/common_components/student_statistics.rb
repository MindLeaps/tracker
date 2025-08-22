class CommonComponents::StudentStatistics < ViewComponent::Base
  include ApplicationHelper

  def initialize(student_lesson_summaries)
    @student_lesson_summaries = student_lesson_summaries
    @total_students = @student_lesson_summaries.count
    @total_attending_students = @student_lesson_summaries.where.not(average_mark: nil).count
    @sum_of_average_marks = @student_lesson_summaries.where.not(average_mark: nil).sum(:average_mark)
    @average_mark_across_students = @total_attending_students.positive? ? (@sum_of_average_marks / @total_attending_students.to_f).round(2) : 0
    @absent_students = @total_students - @total_attending_students
  end

  erb_template <<~ERB
    <div>
      <dl class="mt-14 grid grid-cols-2 gap-5 sm:grid-cols-2">
      <div class="overflow-hidden rounded-lg bg-white px-4 py-5 shadow-sm sm:p-6">
        <dt class="truncate text-sm font-medium text-gray-500"><%= t(:total_nr_of_students) %>:</dt>
        <dd class="mt-1 text-3xl font-semibold tracking-tight text-gray-900"><%= @total_students %></dd>
      </div>
      <div class="overflow-hidden rounded-lg bg-white px-4 py-5 shadow-sm sm:p-6">
        <dt class="truncate text-sm font-medium text-gray-500"><%= t(:nr_of_graded_students) %>:</dt>
        <dd class="mt-1 text-3xl font-semibold tracking-tight text-gray-900"><%= @total_attending_students %></dd>
      </div>
      <div class="overflow-hidden rounded-lg bg-white px-4 py-5 shadow-sm sm:p-6">
        <dt class="truncate text-sm font-medium text-gray-500"><%= t(:nr_of_absent_students) %>:</dt>
        <dd class="mt-1 text-3xl font-semibold tracking-tight text-gray-900"><%= @absent_students%></dd>
      </div>
      <div class="overflow-hidden rounded-lg bg-white px-4 py-5 shadow-sm sm:p-6">
        <dt class="truncate text-sm font-medium text-gray-500"><%= t(:average_mark_across_students) %>:</dt>
        <dd class="mt-1 text-3xl font-semibold tracking-tight text-gray-900"><%= @average_mark_across_students %></dd>
      </div>
      </dl>
    </div>
  ERB
end
