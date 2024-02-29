# == Schema Information
#
# Table name: grade_descriptors
#
#  id                :integer          not null, primary key
#  deleted_at        :datetime
#  grade_description :string
#  mark              :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  skill_id          :integer          not null
#
# Indexes
#
#  index_grade_descriptors_on_skill_id_and_mark  (skill_id,mark) UNIQUE
#
# Foreign Keys
#
#  grade_descriptors_skill_id_fk  (skill_id => skills.id)
#
class GradeDescriptorSerializer < ActiveModel::Serializer
  attributes :id, :mark, :grade_description, :skill_id, :deleted_at

  belongs_to :skill
end
