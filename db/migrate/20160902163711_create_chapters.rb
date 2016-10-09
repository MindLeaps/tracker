# frozen_string_literal: true
class CreateChapters < ActiveRecord::Migration[5.0]
  def change
    create_table :chapters do |t|
      t.string :chapter_name, null: false

      t.timestamps null: false
    end
  end
end
