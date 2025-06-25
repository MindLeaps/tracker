class CreateCountries < ActiveRecord::Migration[7.2]
  def up
    create_table :countries do |t|
      t.string :country_name
      t.timestamps
    end
    insert_country_values

    add_reference :organizations, :country, foreign_key: { to_table: :countries }, null: true
    update_view :organization_summaries, version: 4
    update_view :student_tag_table_rows, version: 2
    create_view :country_summaries, version: 1
  end

  def down
    drop_view :country_summaries, if_exists: true
    update_view :student_tag_table_rows, version: 1
    update_view :organization_summaries, version: 3
    remove_reference :organizations, :country, foreign_key: { to_table: :countries }
    drop_table :countries
  end

  def insert_country_values
    execute <<~SQL
      INSERT INTO countries VALUES
      (1, 'USA', now(), now()),
      (2, 'Uganda', now(), now()),
      (3, 'Rwanda', now(), now()),
      (4, 'Kenya', now(), now()),
      (5, 'Guinea', now(), now()),
      (6, 'Mauritania', now(), now()),
      (7, 'North Macedonia', now(), now()),
      (8, 'Demo', now(), now());
    SQL
  end
end
