# frozen_string_literal: true
class AddQuartierToStudents < ActiveRecord::Migration[5.0]
  def change
    add_column :students, :quartier, :string
  end
end
