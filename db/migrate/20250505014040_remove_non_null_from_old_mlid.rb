class RemoveNonNullFromOldMlid < ActiveRecord::Migration[7.2]
  def change
    change_column_null :students, :old_mlid, true
  end
end
