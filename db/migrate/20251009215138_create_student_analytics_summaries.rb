class CreateStudentAnalyticsSummaries < ActiveRecord::Migration[7.2]
  def change
    create_view :student_analytics_summaries
  end
end
