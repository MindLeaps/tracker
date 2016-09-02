class AddChapterToGroups < ActiveRecord::Migration[5.0]
  def change
    add_reference :groups, :chapter, index: true
  end
end
