# frozen_string_literal: true
class AddEstimatedDobToStudents < ActiveRecord::Migration
  def change
    add_column :students, :estimated_dob, :boolean, null: false, default: true
  end
end
