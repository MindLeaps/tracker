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
require 'rails_helper'

RSpec.describe Enrollment, type: :model do
  subject(:enrollment) { create :enrollment, group: group, student: student }

  describe 'relationships' do
    let(:group) { create :group }
    let(:student) { create :student, organization: group.chapter.organization }

    it { should belong_to :group }
    it 'should belong to student' do
      relation = Enrollment.reflect_on_association(:student)
      expect(relation.macro).to eq(:belongs_to)
    end
  end

  describe 'validations' do
    before :each do
      @org = create :organization
      @chapter = create :chapter, organization: @org
      @group = create :group, chapter: @chapter
      @student = create :student, organization: @org
    end

    it 'validates presence of active_since' do
      @enrollment = Enrollment.new(group: @group, student: @student, active_since: nil)

      expect(@enrollment.valid?).to be false
      expect(@enrollment.errors[:active_since]).to include 'can\'t be blank'
    end

    it 'validates that inactive_since is greater than active_since' do
      enrollment = Enrollment.build student: @student, group: @group, active_since: Time.zone.now

      expect(enrollment.valid?).to be true
      enrollment.inactive_since = 1.day.ago
      expect(enrollment.valid?).to be false
      expect(enrollment.errors[:inactive_since]).to eq [I18n.t(:enrollment_end_before_start)]
    end

    it 'validates uniqueness of active enrollment for student and group' do
      existing_enrollment = Enrollment.create student: @student, group: @group, active_since: Time.zone.now
      duplicate_enrollment = Enrollment.create student: existing_enrollment.student, group: existing_enrollment.group, active_since: Time.zone.now

      expect(duplicate_enrollment.valid?).to be false
      expect(duplicate_enrollment.errors[:student]).to include I18n.t(:enrollment_duplicate)

      duplicate_enrollment.group = create :group, chapter: @chapter

      expect(duplicate_enrollment.valid?).to be true
    end

    it 'validates enrollments for same student and group do not overlap with existing ones' do
      existing_enrollment = Enrollment.create student: @student, group: @group, active_since: Time.zone.now
      overlapping_enrollment = Enrollment.create student: existing_enrollment.student, group: existing_enrollment.group, active_since: 1.year.ago, inactive_since: Time.zone.tomorrow

      expect(overlapping_enrollment.valid?).to be false
      expect(overlapping_enrollment.errors[:student]).to include I18n.t(:enrollment_overlap)

      overlapping_enrollment.inactive_since = 1.day.ago

      expect(overlapping_enrollment.valid?).to be true
    end

    it 'validates that student and group belong to the same organization' do
      student = create(:student)
      enrollment = Enrollment.build student:, group: create(:group), active_since: Time.zone.now

      expect(enrollment.valid?).to be false
      expect(enrollment.errors[:student]).to eq [I18n.t(:enrollment_not_same_org)]

      enrollment.group = create(:group, chapter: create(:chapter, organization: student.organization))

      expect(enrollment.valid?).to be true
    end

    it 'validates no overlap with an existing closed enrollment' do
      organization = create :organization
      chapter = create :chapter, organization: organization
      group = create :group, chapter: chapter
      student = create :student, organization: organization

      existing_enrollment = Enrollment.create student:, group: group, active_since: 1.day.ago, inactive_since: Time.zone.now
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

      non_overlapping_enrollment = Enrollment.build student: existing_enrollment.student, group: existing_enrollment.group, active_since: 1.day.from_now, inactive_since: 1.month.from_now

      expect(non_overlapping_enrollment.valid?).to be true

      non_overlapping_enrollment = Enrollment.build student: existing_enrollment.student, group: existing_enrollment.group, active_since: 1.day.from_now

      expect(non_overlapping_enrollment.valid?).to be true
    end

    it 'validates no overlap with an existing open enrollment' do
      organization = create :organization
      chapter = create :chapter, organization: organization
      group = create :group, chapter: chapter
      student = create :student, organization: organization

      existing_enrollment = Enrollment.create student:, group: group, active_since: 1.day.ago
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

    it 'validates no grades are lost when an enrollment\'s dates have been modified' do
      organization = create :organization
      chapter = create :chapter, organization: organization
      group = create :group, chapter: chapter
      student = create :student, organization: organization
      lesson = create :lesson, group: group, date: 10.days.ago
      create :grade, student: student, lesson: lesson, created_at: 10.days.ago

      enrollment = create :enrollment, student: student, group: group, active_since: 10.days.ago
      enrollment.update(active_since: 1.day.ago)

      expect(enrollment.valid?).to be false
      expect(enrollment.errors.size).to eq(1)
      expect(enrollment.errors[:student]).to eq [I18n.t(:cannot_change_enrollment_dates_because_grades)]
    end

    it 'validates no grades are lost when an enrollment has been deleted' do
      organization = create :organization
      chapter = create :chapter, organization: organization
      group = create :group, chapter: chapter
      student = create :student, organization: organization
      lesson = create :lesson, group: group, date: 10.days.ago
      create :grade, student: student, lesson: lesson, created_at: 10.days.ago

      enrollment = create :enrollment, student: student, group: group, active_since: 10.days.ago
      enrollment.mark_for_destruction

      expect(enrollment.valid?).to be false
      expect(enrollment.errors.size).to eq(1)
      expect(enrollment.errors[:student]).to eq [I18n.t(:enrollment_not_deleted_because_grades)]
    end

    it 'validates group has not changed for an active enrollment' do
      organization = create :organization
      chapter = create :chapter, organization: organization
      group = create :group, chapter: chapter
      other_group = create :group, chapter: chapter
      student = create :student, organization: organization

      enrollment = create :enrollment, student: student, group: group
      enrollment.update(group_id: other_group.id)

      expect(enrollment.valid?).to be false
      expect(enrollment.errors.size).to eq(1)
      expect(enrollment.errors[:student]).to eq [I18n.t(:cannot_change_existing_enrollment)]
    end
  end
end
