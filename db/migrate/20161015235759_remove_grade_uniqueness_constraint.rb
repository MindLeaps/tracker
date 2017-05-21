# frozen_string_literal: true

class RemoveGradeUniquenessConstraint < ActiveRecord::Migration[5.0]
  def change
    remove_index :grades, name: 'grade_uniqueness_index'
  end
end
