# frozen_string_literal: true
class CreateStudentImages < ActiveRecord::Migration[5.0]
  def change
    create_table :student_images do |t|
      t.string :image
      t.references :student, null: false
      t.timestamps
    end
  end
end
