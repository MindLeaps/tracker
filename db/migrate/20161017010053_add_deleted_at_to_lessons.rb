# frozen_string_literal: true
class AddDeletedAtToLessons < ActiveRecord::Migration[5.0]
  def change
    add_column :lessons, :deleted_at, :datetime
  end
end
