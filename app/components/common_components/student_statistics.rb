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
    <div class="mt-6">
      <%= render CommonComponents::StatCards.new(
        label: t(:student_statistics),
        columns: 2,
        stats: [
          { title: t(:total_nr_of_students), value: @total_students },
          { title: t(:nr_of_graded_students), value: @total_attending_students },
          { title: t(:nr_of_absent_students), value: @absent_students },
          { title: t(:average_mark_across_students), value: @average_mark_across_students }
        ]
      ) %>
    </div>
  ERB
end
