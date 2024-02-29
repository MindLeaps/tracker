class CreateSkills < ActiveRecord::Migration[5.0]
  def change
    create_table :skills do |t|
      t.string :skill_name, null: false
      t.references :organization, null: false

      t.timestamps null: false
    end
  end
end
