# frozen_string_literal: true

class AddGroupNameToGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :group_name, :string, null: false, default: ''
  end
end
