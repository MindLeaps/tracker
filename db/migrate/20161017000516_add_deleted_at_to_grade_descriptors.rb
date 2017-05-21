# frozen_string_literal: true

class AddDeletedAtToGradeDescriptors < ActiveRecord::Migration[5.0]
  def change
    add_column :grade_descriptors, :deleted_at, :datetime
  end
end
