class CommonComponents::StudentStatistics < ViewComponent::Base
  include ApplicationHelper

   def initialize(student_lesson_summaries)
      @student_lesson_summaries = student_lesson_summaries
      @total_students = @student_lesson_summaries.count
      @total_attending_students = @student_lesson_summaries.where.not(average_mark: nil).count
      @sum_of_average_marks = @student_lesson_summaries.where.not(average_mark: nil).sum(:average_mark)
      @average_mark_across_students = @total_attending_students > 0 ? (@sum_of_average_marks / @total_attending_students.to_f).round(2) : 0
      @absent_students = @total_students - @total_attending_students
    end
end
