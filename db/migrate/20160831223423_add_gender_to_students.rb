class AddGenderToStudents < ActiveRecord::Migration[5.0]
  def change
    add_column :students, :gender, :integer, default: 0, null: false
  end
end
