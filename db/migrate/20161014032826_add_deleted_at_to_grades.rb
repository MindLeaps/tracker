# frozen_string_literal: true

class AddDeletedAtToGrades < ActiveRecord::Migration[5.0]
  def change
    add_column :grades, :deleted_at, :date
  end
end
