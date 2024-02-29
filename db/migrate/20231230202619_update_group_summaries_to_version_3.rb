class UpdateGroupSummariesToVersion3 < ActiveRecord::Migration[7.0]
  def change
    drop_view :organization_summaries, revert_to_version: 2
    drop_view :chapter_summaries, revert_to_version: 3
    update_view :group_summaries, version: 3, revert_to_version: 2
    create_view :chapter_summaries, version: 3
    create_view :organization_summaries, version: 2
  end
end
