class AddMlidsToOrganizations < ActiveRecord::Migration[6.0]
  def up
    execute <<~SQL
      CALL update_records_with_unique_mlids('organizations', 3);
    SQL
  end

  def down
    execute <<~SQL
      ALTER TABLE organizations DROP COLUMN mlid;
    SQL
  end
end
