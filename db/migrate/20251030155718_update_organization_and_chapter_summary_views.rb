class UpdateOrganizationAndChapterSummaryViews < ActiveRecord::Migration[7.2]
  def up
    drop_views
    create_view :chapter_summaries, version: 4
    create_view :organization_summaries, version: 5
  end

  def down
    drop_views
    create_view :chapter_summaries, version: 3
    create_view :organization_summaries, version: 4
  end

  def drop_views
    drop_view :organization_summaries
    drop_view :chapter_summaries
  end
end
