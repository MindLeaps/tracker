# frozen_string_literal: true

class MakeStudentGroupIdNonNull < ActiveRecord::Migration[5.2]
  def change
    Student.where(group_id: nil).delete_all
    change_column_null(:students, :group_id, true)
  end
end
