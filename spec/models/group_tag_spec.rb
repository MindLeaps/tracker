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
require 'rails_helper'

RSpec.describe GroupTag, type: :model do
  describe 'relationships' do
    it { should belong_to :group }
    it { should belong_to :tag }
  end
end
