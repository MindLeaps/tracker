# frozen_string_literal: true
class AddProfileImageToStudents < ActiveRecord::Migration[5.0]
  def change
    add_reference :students, :profile_image, foreign_key: true
  end
end
