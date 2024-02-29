class CreateOrganizations < ActiveRecord::Migration[5.0]
  def change
    create_table :organizations do |t|
      t.string :organization_name, null: false

      t.timestamps
    end
  end
end
