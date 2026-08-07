class CreateGroupTags < ActiveRecord::Migration[7.2]
  def change
    create_table :group_tags, id: false do |t|
      t.belongs_to :group, foreign_key: true, null: false
      t.belongs_to :tag, foreign_key: true, type: :uuid, null: false
      t.timestamps
    end
  end
end
