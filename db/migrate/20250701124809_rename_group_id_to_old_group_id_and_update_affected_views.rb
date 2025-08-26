class RenameGroupIdToOldGroupIdAndUpdateAffectedViews < ActiveRecord::Migration[7.2]
  def up
    drop_view :organization_summaries
    drop_view :chapter_summaries

    rename_column :students, :group_id, :old_group_id

    update_view :group_summaries, version: 4
    update_view :student_lessons, version: 2
    update_view :student_lesson_details, version: 6
    update_view :student_table_rows, version: 5

    create_view :chapter_summaries, version: 3
    create_view :organization_summaries, version: 4
  end

  def down
    drop_view :organization_summaries
    drop_view :chapter_summaries

    rename_column :students, :old_group_id, :group_id

    update_view :group_summaries, version: 3
    update_view :student_lessons, version: 1
    update_view :student_lesson_details, version: 5
    update_view :student_table_rows, version: 4

    create_view :chapter_summaries, version: 3
    create_view :organization_summaries, version: 4
  end
end
