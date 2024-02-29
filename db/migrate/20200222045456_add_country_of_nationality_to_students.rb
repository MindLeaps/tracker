class AddCountryOfNationalityToStudents < ActiveRecord::Migration[5.2]
  def change
    add_column :students, :country_of_nationality, :text
  end
end
