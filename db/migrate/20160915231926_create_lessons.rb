# frozen_string_literal: true
class CreateLessons < ActiveRecord::Migration[5.0]
  def change
    create_table :lessons do |t|
      t.references :group, null: false
      t.date :date, null: false

      t.timestamps
    end
  end
end
