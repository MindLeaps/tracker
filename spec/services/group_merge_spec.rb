require 'rails_helper'

RSpec.describe GroupMerge do
  let(:organization) { create :organization }
  let(:chapter) { create :chapter, organization: }
  let(:destination_group) { create :group, chapter: }
  let(:source_group) { create :group, chapter: }
  let(:merge) { described_class.new(source_group:, destination_group:) }

  describe '#merge!' do
    it 'moves source lessons without destination collisions and deletes the source group' do
      lesson = create(:lesson, group: source_group)

      merge.merge!

      expect(lesson.reload.group).to eq destination_group
      expect(source_group.reload.deleted_at).to be_present
    end

    it 'merges colliding lessons, keeps higher grades, and hard-deletes the source lesson' do
      subject = create(:subject, organization:)
      skill = create(:skill_with_descriptors, organization:, subject:)
      lower_descriptor = skill.grade_descriptors.find_by(mark: 2)
      higher_descriptor = skill.grade_descriptors.find_by(mark: 5)
      date = Time.zone.today
      source_lesson = create(:lesson, group: source_group, subject:, date:)
      destination_lesson = create(:lesson, group: destination_group, subject:, date:)
      first_student = create(:student, organization:)
      second_student = create(:student, organization:)
      third_student = create(:student, organization:)

      destination_grade = create(:grade, student: first_student, lesson: destination_lesson, grade_descriptor: lower_descriptor)
      create(:grade, student: first_student, lesson: source_lesson, grade_descriptor: higher_descriptor)
      create(:grade, student: second_student, lesson: destination_lesson, grade_descriptor: higher_descriptor)
      create(:grade, student: second_student, lesson: source_lesson, grade_descriptor: lower_descriptor)
      moved_grade = create(:grade, student: third_student, lesson: source_lesson, grade_descriptor: higher_descriptor)

      merge.merge!

      expect(destination_grade.reload.mark).to eq 5
      expect(moved_grade.reload.lesson).to eq destination_lesson
      expect(destination_lesson.grades.exclude_deleted.where(student: second_student, skill:).pick(:mark)).to eq 5
      expect(Lesson.exists?(source_lesson.id)).to be false
      expect(DeletedLesson.exists?(id: source_lesson.id, group: source_group)).to be true
      expect(Grade.where(lesson_id: source_lesson.id)).to be_empty
    end

    it 'normalizes source and destination enrollments into destination enrollments' do
      student = create(:student, organization:)
      create(:enrollment, student:, group: destination_group, active_since: Date.new(2026, 1, 1), inactive_since: Date.new(2026, 1, 31))
      create(:enrollment, student:, group: source_group, active_since: Date.new(2026, 2, 1), inactive_since: Date.new(2026, 2, 28))
      create(:enrollment, student:, group: source_group, active_since: Date.new(2026, 4, 1), inactive_since: Date.new(2026, 4, 30))

      merge.merge!

      expect(source_group.enrollments.where(student:)).to be_empty
      expect(destination_group.enrollments.where(student:).order(:active_since).pluck(:active_since, :inactive_since)).to eq [
        [Date.new(2026, 1, 1), Date.new(2026, 2, 28)],
        [Date.new(2026, 4, 1), Date.new(2026, 4, 30)]
      ]
    end

    it 'keeps merged enrollment ranges open-ended when destination was open-ended' do
      student = create(:student, organization:)
      create(:enrollment, student:, group: destination_group, active_since: Date.new(2026, 1, 1), inactive_since: nil)
      create(:enrollment, student:, group: source_group, active_since: Date.new(2026, 2, 1), inactive_since: Date.new(2026, 2, 28))

      merge.merge!

      expect(destination_group.enrollments.where(student:).sole).to have_attributes(
        active_since: Date.new(2026, 1, 1),
        inactive_since: nil
      )
    end

    it 'blocks invalid merge directions' do
      other_group = create(:group)
      merge = described_class.new(source_group: other_group, destination_group:)

      expect { merge.merge! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
