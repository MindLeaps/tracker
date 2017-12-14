# frozen_string_literal: true

class CreateGrades < ActiveRecord::Migration[5.0]
  def change
    # rubocop:disable Rails/CreateTableWithTimestamps
    create_table :grades do |t|
      t.belongs_to :student, null: false
      t.belongs_to :lesson, null: false
      t.belongs_to :grade_descriptor, null: false

      t.index %i[student_id lesson_id grade_descriptor_id], unique: true, name: 'grade_uniqueness_index'
    end
    # rubocop:enable Rails/CreateTableWithTimestamps
  end
end
