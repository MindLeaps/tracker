class AddDeletedAtToAssignments < ActiveRecord::Migration[5.0]
  def change
    add_column :assignments, :deleted_at, :datetime
  end
end
