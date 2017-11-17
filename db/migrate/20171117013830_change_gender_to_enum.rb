# frozen_string_literal: true

class ChangeGenderToEnum < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      CREATE TYPE gender AS ENUM ('male', 'female');
      ALTER TABLE students ALTER COLUMN gender DROP DEFAULT;
      ALTER TABLE students
        ALTER COLUMN gender SET DATA TYPE gender USING (
          CASE gender::integer
            WHEN 0 then 'male'::gender
            WHEN 1 then 'female'::gender
          END
        );
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE students
        ALTER COLUMN gender SET DATA TYPE integer USING (
          CASE gender::gender
            WHEN 'male' then 0
            WHEN 'female' then 1
          END
        );
      ALTER TABLE students ALTER COLUMN gender SET DEFAULT 0;
      DROP TYPE gender;
    SQL
  end
end
