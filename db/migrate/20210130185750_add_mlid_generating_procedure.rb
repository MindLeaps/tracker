# frozen_string_literal: true

class AddMlidGeneratingProcedure < ActiveRecord::Migration[6.0]
  def up
    execute <<~SQL
      CREATE OR REPLACE PROCEDURE update_records_with_unique_mlids(table_name IN TEXT, mlid_length IN INT)
      AS $$
      DECLARE
          rec RECORD;
          new_mlid TEXT;
      BEGIN
          EXECUTE format('ALTER TABLE %I ADD COLUMN mlid VARCHAR(%s) UNIQUE CONSTRAINT uppercase CHECK(mlid = UPPER(mlid));', table_name, mlid_length);
          FOR rec IN EXECUTE format('SELECT * FROM %I', table_name) LOOP
              LOOP
                  IF rec.mlid IS NOT NULL THEN
                      EXIT;
                  END IF;
                  new_mlid := SUBSTRING(UPPER(MD5(''||NOW()::TEXT||RANDOM()::TEXT)) FOR mlid_length);
                  BEGIN
                     UPDATE organizations SET mlid = new_mlid WHERE id = rec.id;
                     EXIT; -- we successfully updated the record so we can exit this iteration and continue to the next one
                  EXCEPTION WHEN unique_violation THEN
                      -- we catch the exception and let this loop iteration run again
                  END;
              END LOOP;
          END LOOP;
          EXECUTE format('ALTER TABLE %I ALTER COLUMN mlid SET NOT NULL;', table_name);
      END;
      $$ LANGUAGE plpgsql;
    SQL
  end

  def down
    execute <<~SQL
      DROP PROCEDURE update_records_with_unique_mlids;
    SQL
  end
end
