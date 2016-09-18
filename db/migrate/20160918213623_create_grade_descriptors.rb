class CreateGradeDescriptors < ActiveRecord::Migration[5.0]
  def change
    create_table :grade_descriptors do |t|
      t.integer :mark, null: false
      t.string :grade_description
      t.belongs_to :skill, index: true, null: false
    end
  end
end
