# == Schema Information
#
# Table name: organization_lesson_summaries
#
#  grade_count        :bigint
#  group_chapter_name :text
#  lesson_date        :date
#  chapter_id         :integer
#  group_id           :integer
#  lesson_id          :uuid             primary key
#  organization_id    :integer
#  subject_id         :integer
#
class OrganizationLessonSummary < ApplicationRecord
  self.primary_key = :lesson_id

  belongs_to :organization
  belongs_to :chapter
  belongs_to :group

  def readonly?
    true
  end
end
