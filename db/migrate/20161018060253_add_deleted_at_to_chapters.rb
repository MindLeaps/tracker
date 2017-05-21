# frozen_string_literal: true

class AddDeletedAtToChapters < ActiveRecord::Migration[5.0]
  def change
    add_column :chapters, :deleted_at, :datetime
  end
end
