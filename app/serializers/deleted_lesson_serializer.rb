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
class DeletedLessonSerializer < ActiveModel::Serializer
  attributes :id, :lesson_id, :group_id
end
