class CreateStudentTagTableRows < ActiveRecord::Migration[6.0]
  def change
    create_view :student_tag_table_rows
  end
end
