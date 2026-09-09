# == Schema Information
#
# Table name: organization_lesson_summaries
#
#  grade_count        :bigint
#  group_chapter_name :text
#  lesson_date        :date
#  chapter_id         :integer
#  group_id           :integer
#  lesson_id          :uuid             primary key
#  organization_id    :integer
#  subject_id         :integer
#
require 'rails_helper'

RSpec.describe OrganizationLessonSummary, type: :model do
  describe 'query' do
    let(:organization) { create :organization }
    let(:group) { create :group, chapter: create(:chapter, organization:) }
    let(:lesson_date) { Time.zone.today }
    let(:lesson) { create :lesson, group:, date: lesson_date }

    it 'returns qualifying lessons and counts only active grades from eligible students' do
      eligible_student = create(:enrolled_student, organization:, groups: [group])
      ungraded_student = create(:enrolled_student, organization:, groups: [group])
      deleted_student = create(:enrolled_student, organization:, groups: [group], deleted_at: Time.zone.now)
      outside_enrollment = create(:student, organization:)
      create(:enrollment, student: outside_enrollment, group:, active_since: lesson_date + 1.day)

      create(:grade, lesson:, student: eligible_student, grade_descriptor: create(:grade_descriptor))
      create(:grade, lesson:, student: eligible_student, grade_descriptor: create(:grade_descriptor), deleted_at: Time.zone.now)
      create(:grade, lesson:, student: deleted_student, grade_descriptor: create(:grade_descriptor))
      create(:grade, lesson:, student: outside_enrollment, grade_descriptor: create(:grade_descriptor))

      summary = described_class.find_by!(lesson_id: lesson.id)

      expect(summary.organization_id).to eq organization.id
      expect(summary.grade_count).to eq 1
      expect(summary.group_chapter_name).to eq "#{group.group_name} - #{group.chapter.chapter_name}"
      expect(ungraded_student).to be_present
      expect(summary).to be_readonly
    end

    it 'excludes lessons without a non-deleted student enrolled on the lesson date' do
      student = create(:student, organization:)
      create(:enrollment, student:, group:, active_since: lesson_date + 1.day)

      expect(described_class.find_by(lesson_id: lesson.id)).to be_nil
    end
  end
end
