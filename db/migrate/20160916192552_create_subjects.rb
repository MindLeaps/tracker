# frozen_string_literal: true
class CreateSubjects < ActiveRecord::Migration[5.0]
  def change
    create_table :subjects do |t|
      t.string :subject_name, null: false
      t.references :organization, null: false

      t.timestamps null: false
    end
  end
end
