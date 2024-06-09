# == Schema Information
#
# Table name: lessons
#
#  id         :uuid             not null, primary key
#  date       :date             not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group_id   :integer          not null
#  old_id     :integer          not null
#  subject_id :integer          not null
#
# Indexes
#
#  index_lessons_on_group_id                          (group_id)
#  index_lessons_on_group_id_and_subject_id_and_date  (group_id,subject_id,date) UNIQUE WHERE (deleted_at IS NULL)
#  index_lessons_on_id                                (id) UNIQUE
#  index_lessons_on_subject_id                        (subject_id)
#  lesson_uuid_unique                                 (id) UNIQUE
#
# Foreign Keys
#
#  lessons_group_id_fk    (group_id => groups.id)
#  lessons_subject_id_fk  (subject_id => subjects.id)
#
class LessonSerializer < ActiveModel::Serializer
  attributes :id, :group_id, :subject_id, :date, :deleted_at

  belongs_to :group
  belongs_to :subject
end
