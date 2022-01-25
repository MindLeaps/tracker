class AddMoreGenderOptions < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL.squish
      ALTER TABLE students
      ADD old_gender gender;
      UPDATE students SET old_gender = gender;
      ALTER TYPE gender ADD VALUE 'nonbinary';
      ALTER TYPE gender ADD VALUE 'undecided';
    SQL
  end

  def down
    execute <<~SQL.squish
      UPDATE students SET gender = old_gender
      WHERE old_gender IS NOT null;
      ALTER TABLE students
      DROP COLUMN old_gender;
      ALTER TYPE gender RENAME TO gender_enum_deleted;
      CREATE TYPE gender AS ENUM('male', 'female');
      UPDATE students SET notes = notes || ' ' || gender
      WHERE gender = 'undecided' OR gender = 'nonbinary'
      AND notes IS NOT LIKE '%' || gender || '%';
      AND notes IS NOT NULL;
      UPDATE students SET notes = gender
      WHERE gender = 'undecided'
      OR gender = 'nonbinary'
      AND notes IS null;
      UPDATE students SET gender = 'male'
      WHERE gender = 'nonbinary'
      OR gender = 'undecided';
    SQL
  end
end
