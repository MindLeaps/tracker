# frozen_string_literal: true
class CreateAssignments < ActiveRecord::Migration[5.0]
  def change
    create_table :assignments do |t|
      t.belongs_to :skill, index: true, null: false
      t.belongs_to :subject, index: true, null: false
    end
  end
end
