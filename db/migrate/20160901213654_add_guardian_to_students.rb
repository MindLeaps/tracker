# frozen_string_literal: true

# rubocop:disable Rails/BulkChangeTable
class AddGuardianToStudents < ActiveRecord::Migration[5.0]
  def change
    add_column :students, :guardian_name, :string
    add_column :students, :guardian_occupation, :string
    add_column :students, :guardian_contact, :string
    add_column :students, :family_members, :text
  end
end
# rubocop:enable Rails/BulkChangeTable
