# frozen_string_literal: true

class CreateLessonTableRows < ActiveRecord::Migration[5.2]
  def change
    create_view :lesson_table_rows
  end
end
