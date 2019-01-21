# frozen_string_literal: true

class AddUuidToModels < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :uid, :uuid, null: false, default: 'uuid_generate_v4()', index: true, unique: true
    add_column :chapters, :uid, :uuid, null: false, default: 'uuid_generate_v4()', index: true, unique: true
    add_column :groups, :uid, :uuid, null: false, default: 'uuid_generate_v4()', index: true, unique: true
    add_column :students, :uid, :uuid, null: false, default: 'uuid_generate_v4()', index: true, unique: true
    add_column :subjects, :uid, :uuid, null: false, default: 'uuid_generate_v4()', index: true, unique: true
    add_column :skills, :uid, :uuid, null: false, default: 'uuid_generate_v4()', index: true, unique: true
    add_column :assignments, :uid, :uuid, null: false, default: 'uuid_generate_v4()', index: true, unique: true
    add_column :grade_descriptors, :uid, :uuid, null: false, default: 'uuid_generate_v4()', index: true, unique: true
    add_column :lessons, :uid, :uuid, null: false, default: 'uuid_generate_v4()', index: true, unique: true
    add_column :grades, :uid, :uuid, null: false, default: 'uuid_generate_v4()', index: true, unique: true
  end
end
