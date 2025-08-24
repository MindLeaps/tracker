# == Schema Information
#
# Table name: enrollments
#
#  id             :uuid             not null, primary key
#  active_since   :date             not null
#  inactive_since :date
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  group_id       :bigint           not null
#  student_id     :bigint           not null
#
# Indexes
#
#  index_enrollments_on_group_id    (group_id)
#  index_enrollments_on_student_id  (student_id)
#  non_overlapping_enrollments      (student_id, group_id, tsrange((active_since)::timestamp without time zone, (inactive_since)::timestamp without time zone)) USING gist
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id) ON DELETE => cascade
#  fk_rails_...  (student_id => students.id) ON DELETE => cascade
#
FactoryBot.define do
  factory :enrollment do
    group { create :group, chapter: create(:chapter) }
    student { create :student, organization: group.chapter.organization }
    active_since { Time.zone.today }
  end
end
