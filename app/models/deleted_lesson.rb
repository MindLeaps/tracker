# == Schema Information
#
# Table name: deleted_lessons
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group_id   :bigint           not null
#  lesson_id  :uuid             not null
#  subject_id :bigint           not null
#
# Indexes
#
#  index_deleted_lessons_on_group_id    (group_id)
#  index_deleted_lessons_on_lesson_id   (lesson_id) UNIQUE
#  index_deleted_lessons_on_subject_id  (subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#  fk_rails_...  (subject_id => subjects.id)
#
class DeletedLesson < ApplicationRecord
  belongs_to :group
  belongs_to :subject

  scope :by_group, ->(group_id) { where group_id: }
  scope :by_subject, ->(subject_id) { where subject_id: }
end
