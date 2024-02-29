class CreateSubjectSummaries < ActiveRecord::Migration[7.0]
  def change
    create_view :subject_summaries
  end
end
