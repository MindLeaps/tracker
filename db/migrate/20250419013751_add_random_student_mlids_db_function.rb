class AddRandomStudentMlidsDbFunction < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL
      create or replace function random_student_mlids(org_id integer, mlid_length integer default 5, number_of_mlids integer default 10) returns table(mlid text)
      language plpgsql
      as $$
          declare current_values text[];
          begin
              while coalesce(array_length(current_values, 1), 0) < number_of_mlids loop
                      with values as (
                          select random_alphanumeric_string(coalesce(mlid_length, 5)) as value from generate_series(1, number_of_mlids * 2)
                      ),
                      mlids as (
                          select value as mlid from values where value not in (select coalesce(s.mlid, '00000000') from students s where s.organization_id = org_id) limit number_of_mlids
                      )
                      select current_values || array_agg(m.mlid) from mlids m into current_values;
              end loop;
              return query select unnest(current_values[1:number_of_mlids]) as mlid;
          end;
      $$;
    SQL
  end

  def down
    execute <<~SQL
      drop function if exists random_student_mlids(org_id integer);
    SQL
  end
end
