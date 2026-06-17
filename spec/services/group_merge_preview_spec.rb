require 'rails_helper'

RSpec.describe GroupMergePreview do
  let(:organization) { create :organization }
  let(:chapter) { create :chapter, organization: }
  let(:destination_group) { create :group, chapter: }
  let(:source_group) { create :group, chapter: }
  let(:preview) { described_class.new(source_group:, destination_group:) }

  describe '#blockers' do
    it 'blocks groups in different chapters' do
      other_group = create :group, chapter: create(:chapter, organization:)
      preview = described_class.new(source_group: other_group, destination_group:)

      expect(preview.blockers).to include('Groups must belong to the same chapter.')
    end

    it 'blocks deleted groups' do
      source_group.update!(deleted_at: Time.zone.now)

      expect(preview.blockers).to include('Both groups must be active.')
    end
  end

  describe '#lessons_to_move' do
    it 'includes source lessons without destination subject/date collisions' do
      lesson = create :lesson, group: source_group

      expect(preview.lessons_to_move).to contain_exactly(lesson)
      expect(preview.lessons_to_merge).to be_empty
    end
  end

  describe '#lessons_to_merge' do
    it 'includes source lessons with destination subject/date collisions' do
      subject = create(:subject, organization:)
      date = Time.zone.today
      source_lesson = create(:lesson, group: source_group, subject:, date:)
      create(:lesson, group: destination_group, subject:, date:)

      expect(preview.lessons_to_merge).to contain_exactly(source_lesson)
      expect(preview.lessons_to_move).to be_empty
    end
  end

  describe '#grade_summary' do
    it 'summarizes moved grades and duplicate grade winners' do
      subject = create(:subject, organization:)
      skill = create(:skill_with_descriptors, organization:, subject:)
      lower_descriptor = skill.grade_descriptors.find_by(mark: 2)
      higher_descriptor = skill.grade_descriptors.find_by(mark: 5)
      date = Time.zone.today
      source_lesson = create(:lesson, group: source_group, subject:, date:)
      destination_lesson = create(:lesson, group: destination_group, subject:, date:)
      first_student = create(:student, organization:)
      second_student = create(:student, organization:)

      create :grade, student: first_student, lesson: source_lesson, grade_descriptor: higher_descriptor
      create :grade, student: first_student, lesson: destination_lesson, grade_descriptor: lower_descriptor
      create :grade, student: second_student, lesson: source_lesson, grade_descriptor: lower_descriptor

      expect(preview.grade_summary).to eq(
        grades_to_move: 1,
        source_higher: 1,
        destination_kept: 0
      )
    end
  end

  describe '#enrollment_summary' do
    it 'shows merged ranges and preserved gaps' do
      student = create(:student, organization:)
      create(:enrollment, student:, group: destination_group, active_since: Date.new(2026, 1, 1), inactive_since: Date.new(2026, 1, 31))
      create(:enrollment, student:, group: source_group, active_since: Date.new(2026, 2, 1), inactive_since: Date.new(2026, 2, 28))
      create(:enrollment, student:, group: source_group, active_since: Date.new(2026, 4, 1), inactive_since: Date.new(2026, 4, 30))

      expect(preview.enrollment_summary).to include(
        source_enrollments: 2,
        students_affected: 1,
        ranges_before: 3,
        ranges_after: 2,
        students_with_merged_ranges: 1,
        students_with_preserved_gaps: 1
      )
    end

    it 'does not keep a merged range open-ended unless the destination enrollment is open-ended' do
      student = create(:student, organization:)
      create(:enrollment, student:, group: source_group, active_since: Date.new(2026, 1, 1), inactive_since: nil)
      create(:enrollment, student:, group: destination_group, active_since: Date.new(2026, 2, 1), inactive_since: Date.new(2026, 2, 28))

      expect(preview.enrollment_summary).to include(
        ranges_before: 2,
        ranges_after: 1,
        students_with_merged_ranges: 1
      )
    end
  end
end
