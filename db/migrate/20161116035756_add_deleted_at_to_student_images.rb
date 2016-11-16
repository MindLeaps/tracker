class AddDeletedAtToStudentImages < ActiveRecord::Migration[5.0]
  def change
    add_column :student_images, :deleted_at, :datetime
  end
end
