class AddGenderOptions < ActiveRecord::Migration[7.0]
  def up
    execute <<~SQL.squish
      ALTER TYPE gender ADD VALUE 'non-binary';
      ALTER TYPE gender ADD VALUE 'other';
    SQL
  end

  def down
    execute <<~SQL.squish
      DROP TYPE gender;
      DO $$
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'gender') THEN
                CREATE TYPE gender AS ENUM ('male', 'female');
            END IF;
        END
      $$;
      UPDATE TABLE students SET gender = 'male'::gender
      WHERE gender = 'non-binary'::gender OR gender = 'other'::gender;
    SQL
  end
end
