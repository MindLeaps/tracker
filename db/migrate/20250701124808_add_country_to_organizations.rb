class AddCountryToOrganizations < ActiveRecord::Migration[7.2]
  def change
    add_column :organizations, :country, :string, null: true
    add_column :organizations, :country_code, :string, null: true
    update_view :organization_summaries, version: 4, revert_to_version: 3
    update_view :student_tag_table_rows, version: 2, revert_to_version: 1
  end
end
