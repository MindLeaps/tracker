class AddSubjectSkillIndexToAssignments < ActiveRecord::Migration[7.1]
  def change
    # Remove unused assignments
    Assignment.where.not(deleted_at: nil).delete_all

    add_index :assignments, [:subject_id, :skill_id], unique: true
  end
end
