# frozen_string_literal: true
class AddOrganizationToStudents < ActiveRecord::Migration[5.0]
  def change
    add_reference :students, :organization, index: true
    change_column :students, :organization_id, :integer, null: false
  end
end
