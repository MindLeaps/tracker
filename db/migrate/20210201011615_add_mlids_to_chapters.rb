class AddMlidsToChapters < ActiveRecord::Migration[6.0]
  def up
    execute <<~SQL
      CALL update_records_with_unique_mlids('chapters', 2, 'organization_id');
    SQL
  end

  def down
    execute <<~SQL
      ALTER TABLE chapters DROP COLUMN mlid;
    SQL
  end
end
