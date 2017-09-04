# frozen_string_literal: true

class ChangeResearcherToGlobalGuest < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      UPDATE roles
      SET name = 'global_guest'
      WHERE name = 'researcher' AND resource_id IS NULL
    SQL
  end

  def down
    execute <<-SQL
      UPDATE roles
      SET name = 'researcher'
      WHERE name = 'global_guest'
    SQL
  end
end
