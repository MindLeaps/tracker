# frozen_string_literal: true

class AddMlidsToGroups < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
      CALL update_records_with_unique_mlids('groups', 2, 'chapter_id');
    SQL
  end

  def down
    execute <<~SQL
      ALTER TABLE groups DROP COLUMN mlid;
    SQL
  end
end
