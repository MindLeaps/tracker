class AddMlidToStudents < ActiveRecord::Migration[5.0]
  def change
    add_column :students, :mlid, :string
    change_column :students, :mlid, :string, null: false
  end
end
