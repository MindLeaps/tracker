# frozen_string_literal: true

class AddSubjectToLesson < ActiveRecord::Migration[5.0]
  def change
    add_reference :lessons, :subject, index: true
    change_column :lessons, :subject_id, :integer, null: false
  end
end
