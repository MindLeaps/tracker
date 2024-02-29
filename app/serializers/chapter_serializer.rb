# == Schema Information
#
# Table name: chapters
#
#  id              :integer          not null, primary key
#  chapter_name    :string           not null
#  deleted_at      :datetime
#  mlid            :string(2)        not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :integer
#
# Indexes
#
#  index_chapters_on_organization_id  (organization_id)
#  unique_mlid_per_scope              (mlid,organization_id) UNIQUE
#
# Foreign Keys
#
#  chapters_organization_id_fk  (organization_id => organizations.id)
#
class ChapterSerializer < ActiveModel::Serializer
  attributes :id, :chapter_name, :organization_id

  belongs_to :organization
  has_many :groups
end
