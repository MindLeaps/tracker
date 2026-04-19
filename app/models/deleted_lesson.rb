# == Schema Information
#
# Table name: deleted_lessons
#
#  created_at :datetime         not null
#  id         :uuid             not null, primary key
#  updated_at :datetime         not null
#  group_id   :bigint           not null
#
# Indexes
#
#  index_deleted_lessons_on_group_id  (group_id)
#
class DeletedLesson < ApplicationRecord
  belongs_to :group

  scope :by_group, ->(group_id) { where group_id: }

  def lesson_id
    id
  end
end
