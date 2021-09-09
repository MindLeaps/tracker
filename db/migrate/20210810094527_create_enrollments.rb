# frozen_string_literal: true

class CreateEnrollments < ActiveRecord::Migration[6.1]
  def change
    create_table :enrollments, id: :uuid do |t|
      t.belongs_to :student, null: false
      t.belongs_to :group, null: false
      t.datetime :active_since, null: false
      t.datetime :inactive_since

      t.timestamps
    end
  end
end
