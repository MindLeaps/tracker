class ChangeAdminToGlobalAdmin < ActiveRecord::Migration[5.1]
  def up
    execute <<~SQL.squish
      UPDATE roles
      SET name = 'global_admin'
      WHERE name = 'admin'
    SQL
  end

  def down
    execute <<~SQL.squish
      UPDATE roles
      SET name = 'admin'
      WHERE name = 'global_admin'
    SQL
  end
end
