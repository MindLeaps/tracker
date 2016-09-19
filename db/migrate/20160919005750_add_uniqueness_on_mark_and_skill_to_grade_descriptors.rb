class AddUniquenessOnMarkAndSkillToGradeDescriptors < ActiveRecord::Migration[5.0]
  def change
    add_index :grade_descriptors, [:mark, :skill_id], unique: true
  end
end
