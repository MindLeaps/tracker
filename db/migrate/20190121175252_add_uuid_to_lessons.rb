# frozen_string_literal: true

class AddUuidToLessons < ActiveRecord::Migration[5.2]
  def up
    add_column :lessons, :uid, :uuid, null: false, default: 'uuid_generate_v4()', index: { unique: true }

    execute <<~SQL
      ALTER TABLE lessons ADD CONSTRAINT lesson_uuid_unique UNIQUE(uid);
    SQL
  end

  def down
    remove_column :lessons, :uid
  end
end
