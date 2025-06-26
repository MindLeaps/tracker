class AddNewMlidColumn < ActiveRecord::Migration[7.2]
  def up
    rename_column :students, :mlid, :old_mlid
    add_column :students, :mlid, :string, limit: 8
    update_view :student_table_rows, version: 4
  end

  def down
    drop_view :student_table_rows
    remove_column :students, :mlid
    rename_column :students, :old_mlid, :mlid
    create_view :student_table_rows, version: 4
  end
end
