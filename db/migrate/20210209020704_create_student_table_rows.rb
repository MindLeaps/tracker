# frozen_string_literal: true

class CreateStudentTableRows < ActiveRecord::Migration[6.0]
  def change
    create_view :student_table_rows
  end
end
