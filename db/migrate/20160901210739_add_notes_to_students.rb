class AddNotesToStudents < ActiveRecord::Migration[5.0]
  def change
    add_column :students, :notes, :text
  end
end
