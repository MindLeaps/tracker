# frozen_string_literal: true

class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.timestamps null: false
    end
  end
end
