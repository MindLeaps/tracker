# == Schema Information
#
# Table name: assignments
#
#  id         :integer          not null, primary key
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  skill_id   :integer          not null
#  subject_id :integer          not null
#
# Indexes
#
#  index_assignments_on_skill_id                 (skill_id)
#  index_assignments_on_subject_id               (subject_id)
#  index_assignments_on_subject_id_and_skill_id  (subject_id,skill_id) UNIQUE
#
# Foreign Keys
#
#  assignments_skill_id_fk    (skill_id => skills.id)
#  assignments_subject_id_fk  (subject_id => subjects.id)
#
FactoryBot.define do
  factory :assignment do
    subject { create :subject }
    skill { create :skill }
  end
end
