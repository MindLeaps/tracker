# frozen_string_literal: true

class AddEstimatedDobToStudents < ActiveRecord::Migration[5.0]
  def change
    add_column :students, :estimated_dob, :boolean, null: false, default: true
  end
end
