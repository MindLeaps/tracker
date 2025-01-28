class CreateStudentAverages < ActiveRecord::Migration[7.2]
  def change
    create_view :student_averages
  end
end
