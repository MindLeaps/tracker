# frozen_string_literal: true
class ChangeFilenameToImageInStudentImages < ActiveRecord::Migration[5.0]
  def change
    rename_column :student_images, :filename, :image
  end
end
