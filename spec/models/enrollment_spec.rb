# == Schema Information
#
# Table name: enrollments
#
#  id             :uuid             not null, primary key
#  active_since   :datetime         not null
#  inactive_since :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  group_id       :bigint           not null
#  student_id     :bigint           not null
#
# Indexes
#
#  index_enrollments_on_group_id    (group_id)
#  index_enrollments_on_student_id  (student_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id) ON DELETE => cascade
#  fk_rails_...  (student_id => students.id) ON DELETE => cascade
#
require 'rails_helper'

RSpec.describe Enrollment, type: :model do
  describe 'relationships' do
    it { should belong_to :group }
    it { should belong_to :student }
  end

  describe 'validations' do
    it { should validate_presence_of :active_since }
    it 'validates that inactive_since is greater than active_since' do
      student = create(:student)
      enrollment = Enrollment.build student:, group: create(:group, org: student.organization), active_since: Time.zone.now
      expect(enrollment.valid?).to be true
      enrollment.inactive_since = 1.day.ago
      expect(enrollment.valid?).to be false
      expect(enrollment.errors[:inactive_since]).to eq [I18n.t(:enrollment_end_before_start)]
    end

    it 'validates uniqueness of active enrollment for student and group' do
      student = create(:student)
      existing_enrollment = Enrollment.create student:, group: create(:group, org: student.organization), active_since: Time.zone.now
      duplicate_enrollment = Enrollment.create student: existing_enrollment.student, group: existing_enrollment.group, active_since: Time.zone.now
      expect(duplicate_enrollment.valid?).to be false
      expect(duplicate_enrollment.errors[:student]).to eq [I18n.t(:enrollment_duplicate)]
      duplicate_enrollment.group = create(:group, org: student.organization)
      expect(duplicate_enrollment.valid?).to be true
    end

    it 'validates no overlap with an existing closed enrollment' do
      student = create(:student)
      existing_enrollment = Enrollment.create student:, group: create(:group, org: student.organization), active_since: 1.day.ago, inactive_since: Time.zone.now

      overlapping_enrollment = Enrollment.build student: existing_enrollment.student, group: existing_enrollment.group, active_since: 1.hour.ago
      expect(overlapping_enrollment.valid?).to be false
      expect(overlapping_enrollment.errors[:student]).to eq [I18n.t(:enrollment_overlap)]

      overlapping_enrollment = Enrollment.build student: existing_enrollment.student, group: existing_enrollment.group, active_since: 1.hour.ago, inactive_since: 2.days.from_now
      expect(overlapping_enrollment.valid?).to be false
      expect(overlapping_enrollment.errors[:student]).to eq [I18n.t(:enrollment_overlap)]

      overlapping_enrollment = Enrollment.build student: existing_enrollment.student, group: existing_enrollment.group, active_since: 1.month.ago, inactive_since: 1.hour.ago
      expect(overlapping_enrollment.valid?).to be false
      expect(overlapping_enrollment.errors[:student]).to eq [I18n.t(:enrollment_overlap)]

      overlapping_enrollment = Enrollment.build student: existing_enrollment.student, group: existing_enrollment.group, active_since: 1.month.ago, inactive_since: 1.month.from_now
      expect(overlapping_enrollment.valid?).to be false
      expect(overlapping_enrollment.errors[:student]).to eq [I18n.t(:enrollment_overlap)]

      overlapping_enrollment = Enrollment.build student: existing_enrollment.student, group: existing_enrollment.group, active_since: 2.hours.ago, inactive_since: 1.hour.ago
      expect(overlapping_enrollment.valid?).to be false
      expect(overlapping_enrollment.errors[:student]).to eq [I18n.t(:enrollment_overlap)]

      non_overlapping_enrollment = Enrollment.build student: existing_enrollment.student, group: existing_enrollment.group, active_since: 1.hour.from_now, inactive_since: 1.month.from_now
      expect(non_overlapping_enrollment.valid?).to be true

      non_overlapping_enrollment = Enrollment.build student: existing_enrollment.student, group: existing_enrollment.group, active_since: 1.hour.from_now
      expect(non_overlapping_enrollment.valid?).to be true
    end

    it 'validates no overlap with an existing open enrollment' do
      student = create(:student)
      existing_enrollment = Enrollment.create student:, group: create(:group, org: student.organization), active_since: 1.day.ago

      overlapping_enrollment = Enrollment.build student: existing_enrollment.student, group: existing_enrollment.group, active_since: 1.hour.ago, inactive_since: 2.days.from_now
      expect(overlapping_enrollment.valid?).to be false
      expect(overlapping_enrollment.errors[:student]).to eq [I18n.t(:enrollment_overlap)]

      overlapping_enrollment = Enrollment.build student: existing_enrollment.student, group: existing_enrollment.group, active_since: 1.month.ago, inactive_since: 1.hour.ago
      expect(overlapping_enrollment.valid?).to be false
      expect(overlapping_enrollment.errors[:student]).to eq [I18n.t(:enrollment_overlap)]

      overlapping_enrollment = Enrollment.build student: existing_enrollment.student, group: existing_enrollment.group, active_since: 1.month.ago, inactive_since: 1.month.from_now
      expect(overlapping_enrollment.valid?).to be false
      expect(overlapping_enrollment.errors[:student]).to eq [I18n.t(:enrollment_overlap)]

      overlapping_enrollment = Enrollment.build student: existing_enrollment.student, group: existing_enrollment.group, active_since: 2.hours.ago, inactive_since: 1.hour.ago
      expect(overlapping_enrollment.valid?).to be false
      expect(overlapping_enrollment.errors[:student]).to eq [I18n.t(:enrollment_overlap)]

      non_overlapping_enrollment = Enrollment.build student: existing_enrollment.student, group: existing_enrollment.group, active_since: 1.hour.from_now, inactive_since: 1.month.from_now
      expect(non_overlapping_enrollment.valid?).to be false
      expect(overlapping_enrollment.errors[:student]).to eq [I18n.t(:enrollment_overlap)]
    end

    it 'validates that student and group belong to the same organization' do
      student = create(:student)
      enrollment = Enrollment.build student:, group: create(:group), active_since: Time.zone.now
      expect(enrollment.valid?).to be false
      expect(enrollment.errors[:student]).to eq [I18n.t(:enrollment_not_same_org)]
      enrollment.group = create(:group, chapter: create(:chapter, organization: student.organization))
      expect(enrollment.valid?).to be true
    end
  end
end
