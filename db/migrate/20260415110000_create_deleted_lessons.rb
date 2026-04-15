class CreateDeletedLessons < ActiveRecord::Migration[7.2]
  def change
    create_table :deleted_lessons do |t|
      t.uuid :lesson_id, null: false
      t.references :group, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.datetime :deleted_at, null: false

      t.timestamps
    end

    add_index :deleted_lessons, :lesson_id, unique: true
  end
end
