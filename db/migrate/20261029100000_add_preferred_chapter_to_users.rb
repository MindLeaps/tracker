class AddPreferredChapterToUsers < ActiveRecord::Migration[7.2]
  def change
    add_reference :users, :preferred_chapter, type: :integer, foreign_key: { to_table: :chapters, on_delete: :nullify }
  end
end
