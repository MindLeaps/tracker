# frozen_string_literal: true

class AddUuidToAbsences < ActiveRecord::Migration[5.2]
  def up
    add_column :absences, :uid, :uuid, null: false, default: 'uuid_generate_v4()', index: { unique: true }

    execute <<~SQL
      ALTER TABLE absences ADD CONSTRAINT absence_uuid_unique UNIQUE(uid);
    SQL
  end

  def down
    remove_column :absences, :uid

    execute <<~SQL
      ALTER TABLE absences DROP CONSTRAINT absence_uuid_unique;
    SQL
  end
end
