class UpdateStudentAnalyticsSummaries < ActiveRecord::Migration[7.2]
  def change
    update_view :student_analytics_summaries, version: 2, revert_to_version: 1
  end
end
