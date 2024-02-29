class RemoveOrganizationIdFromStudents < ActiveRecord::Migration[5.2]
  def change
    remove_column :students, :organization_id, :integer
  end
end
