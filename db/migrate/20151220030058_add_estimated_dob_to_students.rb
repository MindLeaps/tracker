class AddEstimatedDobToStudents < ActiveRecord::Migration
  def change
    add_column :students, :estimated_dob, :boolean
    change_column :students, :estimated_dob, :boolean, null: false #This is because of an SQLite bug which won't lett us add a column with a NOT NULL constraint
    # http://stackoverflow.com/questions/3170634/how-to-solve-cannot-add-a-not-null-column-with-default-value-null-in-sqlite3
  end
end
