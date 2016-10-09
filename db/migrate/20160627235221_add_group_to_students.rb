# frozen_string_literal: true
class AddGroupToStudents < ActiveRecord::Migration
  def change
    add_reference :students, :group, index: true
  end
end
