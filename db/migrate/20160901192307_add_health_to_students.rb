class AddHealthToStudents < ActiveRecord::Migration[5.0]
  def change
    add_column :students, :health_insurance, :text
    add_column :students, :health_issues, :text
    add_column :students, :hiv_tested, :boolean
  end
end
