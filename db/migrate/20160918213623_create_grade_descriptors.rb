# frozen_string_literal: true

class CreateGradeDescriptors < ActiveRecord::Migration[5.0]
  def change
    # rubocop:disable Rails/CreateTableWithTimestamps
    create_table :grade_descriptors do |t|
      t.integer :mark, null: false
      t.string :grade_description
      t.belongs_to :skill, null: false

      t.index %i[mark skill_id], unique: true
    end
    # rubocop:enable Rails/CreateTableWithTimestamps
  end
end
