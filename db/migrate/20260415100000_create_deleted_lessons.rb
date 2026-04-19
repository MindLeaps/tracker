class CreateDeletedLessons < ActiveRecord::Migration[7.2]
  def change
    create_table :deleted_lessons, id: :uuid do |t|
      t.bigint :group_id, null: false

      t.timestamps
    end

    add_index :deleted_lessons, :group_id
  end
end
