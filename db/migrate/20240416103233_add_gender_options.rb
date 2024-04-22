class AddGenderOptions < ActiveRecord::Migration[7.0]
  def up
    execute <<~SQL.squish
      ALTER TYPE gender ADD VALUE 'nonbinary';
    SQL
  end

  def down
    execute <<~SQL.squish
      DROP VIEW student_table_rows;

      UPDATE students SET gender = 'male'::gender
      WHERE gender = 'nonbinary'::gender;

      CREATE TYPE new_gender AS ENUM('male','female');

      ALTER TABLE students ALTER COLUMN gender
        SET DATA TYPE new_gender
          USING gender::text::new_gender;

      DROP TYPE gender;
      ALTER TYPE new_gender RENAME TO gender;


      CREATE VIEW student_table_rows AS SELECT s.*,
        g.group_name,
        o.mlid AS organization_mlid,
        c.mlid AS chapter_mlid,
        g.mlid AS group_mlid,
        concat(o.mlid, '-', c.mlid, '-', g.mlid, '-', s.mlid) AS full_mlid
       FROM (((public.students s
         JOIN public.groups g ON ((s.group_id = g.id)))
         JOIN public.chapters c ON ((g.chapter_id = c.id)))
         JOIN public.organizations o ON ((c.organization_id = o.id)));
    SQL
  end
end
