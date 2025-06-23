class CreateCountries < ActiveRecord::Migration[7.2]
  def up
    create_table :countries do |t|
      t.string :country_name
      t.timestamps
    end
    insert_country_values

    add_reference :organizations, :country, foreign_key: { to_table: :countries }, null: true
    update_view :organization_summaries, version: 4
  end

  def down
    update_view :organization_summaries, version: 3
    remove_reference :organizations, :country, foreign_key: { to_table: :countries }
    drop_table :countries
  end

  def insert_country_values
    execute <<~SQL
      INSERT INTO countries VALUES 
      (1, 'North Macedonia', now(), now()),
      (2, 'Guinea', now(), now());
    SQL
  end
end
