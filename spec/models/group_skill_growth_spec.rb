# == Schema Information
#
# Table name: group_skill_growths
#
#  growth     :decimal(, )
#  skill_name :text
#  group_id   :integer
#  skill_id   :bigint
#
require 'rails_helper'

RSpec.describe GroupSkillGrowth, type: :model do
  let(:group) { create :group }
  let(:subject) { create :subject_with_skills, skill_names: %w[Grit Focus], organization: group.chapter.organization }
  let(:grit) { subject.skills.find_by!(skill_name: 'Grit') }
  let(:focus) { subject.skills.find_by!(skill_name: 'Focus') }
  let(:first_student) { create :enrolled_student, organization: group.chapter.organization, groups: [group] }
  let(:second_student) { create :enrolled_student, organization: group.chapter.organization, groups: [group] }

  def add_grade(student:, lesson:, skill:, mark:, deleted_at: nil)
    descriptor = GradeDescriptor.find_or_create_by!(skill:, mark:) { |grade_descriptor| grade_descriptor.grade_description = "Mark #{mark}" }
    create :grade, student:, lesson:, grade_descriptor: descriptor, deleted_at:
  end

  it 'is readonly' do
    first_lesson = create :lesson, group:, subject:, date: 2.days.ago
    second_lesson = create :lesson, group:, subject:, date: 1.day.ago
    add_grade(student: first_student, lesson: first_lesson, skill: grit, mark: 1)
    add_grade(student: first_student, lesson: second_lesson, skill: grit, mark: 5)

    expect(described_class.first.readonly?).to eq true
  end

  it 'averages each active student first-to-last change per skill' do
    first_lesson = create :lesson, group:, subject:, date: 2.days.ago
    second_lesson = create :lesson, group:, subject:, date: 1.day.ago
    add_grade(student: first_student, lesson: first_lesson, skill: grit, mark: 1)
    add_grade(student: first_student, lesson: second_lesson, skill: grit, mark: 5)
    add_grade(student: second_student, lesson: first_lesson, skill: grit, mark: 2)
    add_grade(student: second_student, lesson: second_lesson, skill: grit, mark: 4)

    expect(described_class.find_by!(group_id: group.id, skill_id: grit.id).growth).to eq 3
  end

  it 'requires two eligible grades from the same student and skill' do
    lesson = create :lesson, group:, subject:, date: 1.day.ago
    add_grade(student: first_student, lesson:, skill: grit, mark: 3)
    add_grade(student: second_student, lesson:, skill: grit, mark: 5)

    expect(described_class.where(group_id: group.id, skill_id: grit.id)).to be_empty
  end

  it 'excludes currently inactive and deleted students' do
    first_lesson = create :lesson, group:, subject:, date: 3.days.ago
    second_lesson = create :lesson, group:, subject:, date: 2.days.ago
    [first_student, second_student].each do |student|
      add_grade(student:, lesson: first_lesson, skill: grit, mark: 1)
      add_grade(student:, lesson: second_lesson, skill: grit, mark: 5)
    end
    first_student.enrollments.first.update!(inactive_since: Time.zone.today)
    second_student.update!(deleted_at: Time.zone.now)

    expect(described_class.where(group_id: group.id, skill_id: grit.id)).to be_empty
  end

  it 'excludes deleted grades, deleted lessons, and grades outside the enrollment period' do
    valid_lesson = create :lesson, group:, subject:, date: 2.days.ago
    deleted_lesson = create :lesson, group:, subject:, date: 1.day.ago, deleted_at: Time.zone.now
    outside_enrollment = create :lesson, group:, subject:, date: 2.years.ago
    add_grade(student: first_student, lesson: valid_lesson, skill: grit, mark: 2)
    add_grade(student: first_student, lesson: deleted_lesson, skill: grit, mark: 6)
    add_grade(student: first_student, lesson: outside_enrollment, skill: grit, mark: 1)
    add_grade(student: first_student, lesson: valid_lesson, skill: focus, mark: 3, deleted_at: Time.zone.now)

    expect(described_class.where(group_id: group.id)).to be_empty
  end

  it 'keeps same-named skills separate and orders same-date lessons deterministically' do
    other_subject = create :subject, organization: group.chapter.organization
    same_named_skill = create :skill_with_descriptors, skill_name: grit.skill_name, organization: group.chapter.organization, subject: other_subject
    early_id_lesson = create :lesson, id: '00000000-0000-0000-0000-000000000001', group:, subject:, date: 1.day.ago
    late_id_lesson = create :lesson, id: 'ffffffff-ffff-ffff-ffff-ffffffffffff', group:, subject: other_subject, date: 1.day.ago

    add_grade(student: first_student, lesson: early_id_lesson, skill: grit, mark: 1)
    add_grade(student: first_student, lesson: late_id_lesson, skill: grit, mark: 5)
    add_grade(student: first_student, lesson: early_id_lesson, skill: same_named_skill, mark: 6)
    add_grade(student: first_student, lesson: late_id_lesson, skill: same_named_skill, mark: 2)

    growths = described_class.where(group_id: group.id).index_by(&:skill_id)
    expect(growths.fetch(grit.id).growth).to eq 4
    expect(growths.fetch(same_named_skill.id).growth).to eq(-4)
  end
end
