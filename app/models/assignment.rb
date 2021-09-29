# frozen_string_literal: true

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
#  index_assignments_on_skill_id    (skill_id)
#  index_assignments_on_subject_id  (subject_id)
#
# Foreign Keys
#
#  assignments_skill_id_fk    (skill_id => skills.id)
#  assignments_subject_id_fk  (subject_id => subjects.id)
#
class Assignment < ApplicationRecord
  belongs_to :skill
  belongs_to :subject

  validates :skill, presence: true
  validates :subject, presence: true

  def destroy
    update deleted_at: Time.zone.now
  end
end
