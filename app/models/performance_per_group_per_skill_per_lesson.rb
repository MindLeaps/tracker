# frozen_string_literal: true

# == Schema Information
#
# Table name: performance_per_group_per_skill_per_lessons
#
#  date               :date
#  group_chapter_name :text
#  group_name         :string
#  mark               :float
#  skill_name         :string
#  group_id           :integer
#  lesson_id          :integer
#  skill_id           :integer
#  subject_id         :integer
#
class PerformancePerGroupPerSkillPerLesson < ApplicationRecord
  belongs_to :group
  belongs_to :lesson
  belongs_to :skill
end
