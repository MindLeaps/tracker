class GenerateNewStudentMlids < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL.squish
      with org_student_counts as (select o.id as organization_id, count(*) as student_count from students s join organizations o on s.organization_id = o.id group by o.id),
      org_with_mlids as (select organization_id, mlid from org_student_counts cross join random_student_mlids(organization_id, 8, student_count::integer) order by mlid),
      org_with_mlids_rn as (select organization_id, mlid, row_number() over (partition by organization_id) as rn from org_with_mlids),
      students_with_rn as (select id, organization_id, row_number() over (partition by organization_id) as rn from students),
      student_id_to_mlid as (select id, mlid from students_with_rn s join org_with_mlids_rn o on s.organization_id = o.organization_id AND s.rn = o.rn order by id)
      update students s set mlid = student_id_to_mlid.mlid from student_id_to_mlid where s.id = student_id_to_mlid.id;
    SQL
    change_column_null :students, :mlid, false
    add_index :students, [:mlid, :organization_id], unique: true
  end

  def down
    remove_index :students, [:mlid, :organization_id]
    change_column_null :students, :mlid, true
    execute <<~SQL.squish
      update students set mlid = null;
    SQL
  end
end
