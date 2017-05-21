# frozen_string_literal: true

class AddProfileImageToStudents < ActiveRecord::Migration[5.0]
  def change
    add_reference :students, :profile_image, foreign_key: { to_table: :student_images }
  end
end
