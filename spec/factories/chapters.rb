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
FactoryBot.define do
  factory :chapter do
    sequence(:chapter_name) { |n| "#{Faker::Movies::StarWars.planet}-#{n}" }
    organization
    sequence(:mlid) { |n| n.to_s(36).rjust(2, '0').upcase }
  end
end
