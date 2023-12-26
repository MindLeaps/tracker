# frozen_string_literal: true

class RolifyCreateRoles < ActiveRecord::Migration[5.0]
  def change
    create_table(:roles) do |t|
      t.string :name
      t.references :resource, polymorphic: true

      t.timestamps
    end

    # rubocop:disable Rails/CreateTableWithTimestamps
    create_table(:users_roles, id: false) do |t|
      t.references :user
      t.references :role
    end
    # rubocop:enable Rails/CreateTableWithTimestamps

    add_index(:roles, :name)
    add_index(:roles, %i[name resource_type resource_id])
    add_index(:users_roles, %i[user_id role_id])
  end
end
