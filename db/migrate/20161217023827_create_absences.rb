# frozen_string_literal: true

class CreateAbsences < ActiveRecord::Migration[5.0]
  def change
    # rubocop:disable Rails/CreateTableWithTimestamps
    create_table :absences do |t|
      t.references :student, foreign_key: true, null: false
      t.references :lesson, foreign_key: true, null: false
    end
    # rubocop:enable Rails/CreateTableWithTimestamps
  end
end
