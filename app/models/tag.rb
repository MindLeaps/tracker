# == Schema Information
#
# Table name: tags
#
#  id              :uuid             not null, primary key
#  shared          :boolean          not null
#  tag_name        :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :bigint           not null
#
# Indexes
#
#  index_tags_on_organization_id  (organization_id)
#
class Tag < ApplicationRecord
  has_many :student_tags, dependent: :destroy
  has_many :students, through: :student_tags
  belongs_to :organization

  validates :tag_name, presence: true
end
