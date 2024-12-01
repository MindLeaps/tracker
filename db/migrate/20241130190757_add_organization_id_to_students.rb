class AddOrganizationIdToStudents < ActiveRecord::Migration[7.2]
  def up
    add_reference :students, :organization, foreign_key: true, null: true
    execute <<-SQL
        UPDATE students SET organization_id = subquery.organization_id FROM (
            select s.id as student_id, o.id as organization_id from students s
            join groups g on s.old_group_id = g.id
            join chapters c on c.id = g.chapter_id
            join organizations o on o.id = c.organization_id
        ) subquery
        where students.id = subquery.student_id
    SQL
    change_column_null :students, :organization_id, true
  end

  def down
    remove_reference :students, :organization, foreign_key: true
  end
end
