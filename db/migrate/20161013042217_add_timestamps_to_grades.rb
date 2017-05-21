# frozen_string_literal: true

class AddTimestampsToGrades < ActiveRecord::Migration[5.0]
  def change
    add_column :grades, :created_at, :datetime
    add_column :grades, :updated_at, :datetime

    change_column :grades, :created_at, :datetime, null: false
    change_column :grades, :updated_at, :datetime, null: false
  end
end
