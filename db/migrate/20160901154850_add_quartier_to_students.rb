class AddQuartierToStudents < ActiveRecord::Migration[5.0]
  def change
    add_column :students, :quartier, :string
  end
end
