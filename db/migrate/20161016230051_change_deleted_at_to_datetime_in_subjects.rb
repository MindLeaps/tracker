class ChangeDeletedAtToDatetimeInSubjects < ActiveRecord::Migration[5.0]
  def change
    change_column :subjects, :deleted_at, :datetime
  end
end
