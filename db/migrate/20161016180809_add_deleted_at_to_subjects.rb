class AddDeletedAtToSubjects < ActiveRecord::Migration[5.0]
  def change
    add_column :subjects, :deleted_at, :date
  end
end
