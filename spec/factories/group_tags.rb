# == Schema Information
#
# Table name: group_tags
#
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group_id   :bigint           not null
#  tag_id     :uuid             not null
#
# Indexes
#
#  index_group_tags_on_group_id  (group_id)
#  index_group_tags_on_tag_id    (tag_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#  fk_rails_...  (tag_id => tags.id)
#
FactoryBot.define do
  factory :group_tag do
    group { create :group }
    tag { create :tag }
  end
end
