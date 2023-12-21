# frozen_string_literal: true

# == Schema Information
#
# Table name: student_tags
#
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  student_id :bigint           not null
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
FactoryBot.define do
  factory :student_tag do
    student { create :student }
    tag { create :tag }
  end
end
