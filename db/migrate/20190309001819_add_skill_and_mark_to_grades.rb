# frozen_string_literal: true

class AddSkillAndMarkToGrades < ActiveRecord::Migration[5.2]
  # rubocop:disable Metrics/MethodLength
  def up
    add_reference :grades, :skill, foreign_key: true
    add_column :grades, :mark, :integer

    remove_index :grade_descriptors, name: :index_grade_descriptors_on_mark_and_skill_id
    add_index :grade_descriptors, %i[skill_id mark], unique: true

    execute <<~SQL
      UPDATE grades
        SET skill_id = gd.skill_id, mark = gd.mark
        FROM grade_descriptors gd
        WHERE gd.id = grades.grade_descriptor_id;
    SQL

    change_column_null :grades, :mark, false
    change_column_null :grades, :skill_id, false
  end

  def down
    remove_column :grades, :skill_id
    remove_column :grades, :mark
    remove_index :grade_descriptors, colummn: %i[skill_id mark]
    add_index :grade_descriptors, %i[mark skill_id], unique: true
  end
  # rubocop:enable Metrics/MethodLength
end
