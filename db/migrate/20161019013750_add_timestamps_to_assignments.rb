class AddTimestampsToAssignments < ActiveRecord::Migration[5.0]
  def change
    add_column :assignments, :created_at, :datetime
    add_column :assignments, :updated_at, :datetime

    change_column :assignments, :created_at, :datetime, null: false
    change_column :assignments, :updated_at, :datetime, null: false
  end
end
