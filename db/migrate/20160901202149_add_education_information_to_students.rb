class AddEducationInformationToStudents < ActiveRecord::Migration[5.0]
  def change
    add_column :students, :name_of_school, :string
    add_column :students, :school_level_completed, :string
    add_column :students, :year_of_dropout, :integer
    add_column :students, :reason_for_leaving, :string
  end
end
