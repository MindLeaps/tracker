# frozen_string_literal: true
class AddUniqueIndexToLessons < ActiveRecord::Migration[5.0]
  def change
    add_index(:lessons, [:group_id, :subject_id, :date], unique: true, where: 'deleted_at is null')
  end
end
