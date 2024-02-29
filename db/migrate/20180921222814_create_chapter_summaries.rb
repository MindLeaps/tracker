class CreateChapterSummaries < ActiveRecord::Migration[5.2]
  def change
    create_view :chapter_summaries
  end
end
