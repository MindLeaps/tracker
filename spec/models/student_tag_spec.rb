# frozen_string_literal: true

# == Schema Information
#
# Table name: student_tags
#
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  student_id :integer          not null
#  tag_id     :uuid             not null
#
# Indexes
#
#  index_student_tags_on_student_id  (student_id)
#  index_student_tags_on_tag_id      (tag_id)
#
# Foreign Keys
#
#  fk_rails_...  (student_id => students.id)
#  fk_rails_...  (tag_id => tags.id)
#
require 'rails_helper'

RSpec.describe StudentTag, type: :model do
  describe 'relationships' do
    it { should belong_to :student }
    it { should belong_to :tag }
  end
end
