# frozen_string_literal: true
class CreateStudents < ActiveRecord::Migration
  def change
    create_table :students do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.date :dob, null: false

      t.timestamps null: false
    end
  end
end
