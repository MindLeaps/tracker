class ChangeImageToFilenameInStudentImages < ActiveRecord::Migration[5.0]
  def change
    rename_column :student_images, :image, :filename
  end
end
