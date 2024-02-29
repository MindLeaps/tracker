class AddOnDeleteToUsersRoles < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key :users_roles, :users
    add_foreign_key :users_roles, :users, on_delete: :cascade, name: 'users_roles_user_id_fk'

    remove_foreign_key :users_roles, :roles
    add_foreign_key :users_roles, :roles, on_delete: :cascade, name: 'users_roles_role_id_fk'
  end

  def down
    remove_foreign_key :users_roles, :users
    remove_foreign_key :users_roles, :roles

    add_foreign_key :users_roles, :users, name: 'users_roles_user_id_fk'
    add_foreign_key :users_roles, :roles, name: 'users_roles_role_id_fk'
  end
end
