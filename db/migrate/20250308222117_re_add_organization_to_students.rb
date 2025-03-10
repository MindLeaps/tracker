class ReAddOrganizationToStudents < ActiveRecord::Migration[7.2]
  def up
    add_reference :students, :organization, index: true, foreign_key: true
    execute <<~SQL
      update students#{' '}
      set organization_id = c.organization_id
      from groups g join chapters c on g.chapter_id = c.id
      where g.id = students.group_id
    SQL
    change_column :students, :organization_id, :integer, null: false
  end

  def down
    remove_column :students, :organization_id
  end
end
