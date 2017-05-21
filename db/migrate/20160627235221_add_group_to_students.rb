# frozen_string_literal: true

class AddGroupToStudents < ActiveRecord::Migration[5.0]
  def change
    add_reference :students, :group, index: true
  end
end
