# frozen_string_literal: true

class CreateTags < ActiveRecord::Migration[6.0]
  # rubocop:disable Metrics/MethodLength
  def up
    enable_extension 'pgcrypto' unless extensions.include? 'pgcrypto'

    create_table :tags, id: :uuid do |t|
      t.string :tag_name, null: false
      t.belongs_to :organization, null: false
      t.boolean :shared, null: false
      t.timestamps
    end

    create_table :student_tags, id: false do |t|
      t.belongs_to :student, foreign_key: true, null: false
      t.belongs_to :tag, foreign_key: true, type: :uuid, null: false
      t.timestamps
    end
  end

  def down
    drop_table :student_tags
    drop_table :tags
  end
  # rubocop:enable Metrics/MethodLength
end
