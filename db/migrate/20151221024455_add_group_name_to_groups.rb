class AddGroupNameToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :group_name, :string, null: false, default: ''
  end
end
