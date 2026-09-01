# == Schema Information
#
# Table name: group_skill_growths
#
#  growth     :decimal(, )
#  skill_name :text
#  group_id   :integer
#  skill_id   :bigint
#
class GroupSkillGrowth < ApplicationRecord
  self.primary_key = nil

  def readonly?
    true
  end
end
