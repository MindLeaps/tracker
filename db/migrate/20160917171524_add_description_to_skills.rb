class AddDescriptionToSkills < ActiveRecord::Migration[5.0]
  def change
    add_column :skills, :skill_description, :text
  end
end
