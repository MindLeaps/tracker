class CreateTemporarySummaries < ActiveRecord::Migration[7.2]
  def change
    create_view :temporary_summaries
  end
end
