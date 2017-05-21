# frozen_string_literal: true

class ChangeDeletedAtToDatetimeInGrades < ActiveRecord::Migration[5.0]
  def change
    change_column :grades, :deleted_at, :datetime
  end
end
