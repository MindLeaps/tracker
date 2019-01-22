# frozen_string_literal: true

class AddTimestampsToGradeDescriptors < ActiveRecord::Migration[5.0]
  def change
    add_column :grade_descriptors, :created_at, :datetime
    add_column :grade_descriptors, :updated_at, :datetime

    change_column :grade_descriptors, :created_at, :datetime, null: false
    change_column :grade_descriptors, :updated_at, :datetime, null: false
  end
end
