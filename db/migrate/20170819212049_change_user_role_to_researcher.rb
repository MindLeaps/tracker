class ChangeUserRoleToResearcher < ActiveRecord::Migration[5.1]
  def up
    execute <<~SQL.squish
      UPDATE roles
      SET name = 'researcher'
      WHERE name = 'user'
    SQL
  end

  def down
    execute <<~SQL.squish
      UPDATE roles
      SET name = 'user'
      WHERE name = 'researcher'
    SQL
  end
end
