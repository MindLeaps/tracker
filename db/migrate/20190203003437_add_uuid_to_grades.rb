# frozen_string_literal: true

class AddUuidToGrades < ActiveRecord::Migration[5.2]
  def up
    add_column :grades, :uid, :uuid, null: false, default: 'uuid_generate_v4()', index: { unique: true }

    execute <<~SQL
      ALTER TABLE grades ADD CONSTRAINT grade_uuid_unique UNIQUE(uid);
    SQL
  end

  def down
    remove_column :grades, :uid
  end
end
