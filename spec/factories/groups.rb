# == Schema Information
#
# Table name: groups
#
#  id         :integer          not null, primary key
#  deleted_at :datetime
#  group_name :string           default(""), not null
#  mlid       :string(2)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  chapter_id :integer
#
# Indexes
#
#  index_groups_on_chapter_id  (chapter_id)
#  unique_mlid_per_chapter_id  (mlid,chapter_id) UNIQUE
#
# Foreign Keys
#
#  groups_chapter_id_fk  (chapter_id => chapters.id)
#
FactoryBot.define do
  factory :group do
    sequence(:group_name) { |n| "#{Faker::Movies::StarWars.vehicle}-#{n}" }
    sequence(:mlid) { |n| n.to_s(36).rjust(2, '0').upcase }
    chapter { create :chapter }
  end
end
