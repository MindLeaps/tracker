require 'rails_helper'

RSpec.describe ChapterDashboard do
  let(:today) { Date.new(2026, 10, 30) }
  let(:organization) { create :organization }
  let(:chapter) { create :chapter, organization: }
  let(:group) { create :group, chapter: }
  let(:subject) { create :subject, organization: }
  let(:skill) { create :skill_with_descriptors, organization:, subject: }
  let(:student) { enrolled_student }
  let(:dashboard) { described_class.new(chapter:, today:) }

  def enrolled_student(inactive_since: nil)
    person = create(:student, organization:)
    create(:enrollment, student: person, group:, active_since: today - 60, inactive_since:)
    person
  end

  def assessment(person, mark, date, **options)
    lesson = Lesson.find_or_create_by!(group: options.fetch(:lesson_group, group), subject: options.fetch(:lesson_subject, subject), date:)
    descriptor = options.fetch(:grade_skill, skill).grade_descriptors.find_by!(mark:)
    create(:grade, student: person, lesson:, grade_descriptor: descriptor)
  end

  def sequence(person, marks, dates: [today - 20, today - 10, today])
    marks.zip(dates).map { |mark, date| assessment(person, mark, date) }
  end

  it 'counts lessons and distinct students and groups in the exact seven-day periods' do
    assessment(student, 3, today - 6)
    assessment(student, 4, today)
    assessment(student, 2, today - 7)
    assessment(student, 1, today - 13)
    assessment(student, 5, today - 14)
    assessment(student, 6, today + 1)

    expect(dashboard.activity).to eq(lessons: [2, 2], students: [1, 1], groups: [1, 1])
    expect(dashboard.daily_lessons.pluck(:count)).to eq [1, 0, 0, 0, 0, 0, 1]
    expect(dashboard.group_overview.first).to include(lessons: 2, students: 1, latest: today)
  end

  it 'counts lessons without grades and handles empty data' do
    create(:lesson, group:, subject:, date: today)

    expect(dashboard.activity).to eq(lessons: [1, 0], students: [0, 0], groups: [1, 0])
    expect(dashboard.declines).to be_empty
    expect(dashboard.improvements).to be_empty
  end

  it 'excludes other chapters, deleted records and grades outside enrollment' do
    invalid = assessment(student, 3, today)
    invalid.update!(deleted_at: Time.current)
    other_group = create(:group, chapter: create(:chapter, organization:))
    create(:lesson, group: other_group, subject:, date: today)
    unenrolled = create(:student, organization:)
    assessment(unenrolled, 4, today)
    deleted_student = enrolled_student
    assessment(deleted_student, 4, today)
    deleted_student.update!(deleted_at: Time.current)

    expect(dashboard.activity).to eq(lessons: [1, 0], students: [0, 0], groups: [1, 0])
    invalid.lesson.update!(deleted_at: Time.current)
    expect(described_class.new(chapter:, today:).activity[:lessons]).to eq [0, 0]
  end

  it 'includes historical activity for ended enrollments but excludes it from learning highlights' do
    former = enrolled_student(inactive_since: today - 1)
    sequence(former, [5, 4, 3], dates: [today - 20, today - 10, today - 2])

    expect(dashboard.activity[:students]).to eq [1, 1]
    expect(dashboard.declines).to be_empty
  end

  it 'finds strict declines and improvements with dated evidence' do
    sequence(student, [6, 4, 3])
    improving = enrolled_student
    sequence(improving, [1, 3, 5])

    expect(dashboard.declines.first).to include(student_id: student.id, change: 3, group_id: group.id, subject_id: subject.id, skill_id: skill.id)
    expect(dashboard.declines.first[:evidence].pluck(:mark)).to eq [6, 4, 3]
    expect(dashboard.improvements.first).to include(student_id: improving.id, change: 4)
  end

  it 'requires the latest three scores to form the pattern and the latest to be recent' do
    sequence(student, [6, 5, 4], dates: [today - 27, today - 20, today - 7])
    expect(dashboard.declines).to be_empty
    assessment(student, 5, today)
    expect(described_class.new(chapter:, today:).declines).to be_empty
  end

  it 'does not join scores across groups, subjects, skills or outside the history window' do
    assessment(student, 7, today - 28)
    assessment(student, 6, today - 20)
    another_subject = create(:subject, organization:)
    assessment(student, 5, today - 10, lesson_subject: another_subject)
    another_skill = create(:skill_with_descriptors, organization:, subject:)
    assessment(student, 4, today, grade_skill: another_skill)
    another_group = create(:group, chapter:)
    create(:enrollment, student:, group: another_group, active_since: today - 60)
    assessment(student, 3, today, lesson_group: another_group)

    expect(dashboard.declines).to be_empty
  end

  it 'chooses the largest decline per student and limits and orders suggestions' do
    people = Array.new(6) { enrolled_student }
    people.each_with_index { |person, index| sequence(person, [7, 6, index.zero? ? 1 : 4]) }
    another_skill = create(:skill_with_descriptors, organization:, subject:)
    [5, 4, 3].zip([today - 20, today - 10, today]).each do |mark, date|
      assessment(people.first, mark, date, grade_skill: another_skill)
    end

    expect(dashboard.declines.size).to eq 5
    expect(dashboard.declines.first).to include(student_id: people.first.id, change: 6)
    expect(dashboard.declines.pluck(:student_id).uniq.size).to eq 5
  end

  it 'weights each student equally using only their latest mark per skill' do
    sequence(student, [1, 2, 7])
    assessment(enrolled_student, 1, today)
    assessment(enrolled_student, 1, today)
    entry = dashboard.snapshot.first

    expect(entry).to include(count: 3, average: 3.0, minimum: 1, maximum: 7)
    expect(dashboard.selected_group).to eq group
    expect(dashboard.selected_subject).to eq subject
  end

  it 'suppresses averages below three students and uses the configured scale' do
    create(:assignment, subject:, skill:) unless subject.skills.exists?(skill.id)
    assessment(student, 3, today)
    expect(dashboard.snapshot.first).to include(count: 1, average: nil)
  end

  it 'restricts requested snapshot filters to the chapter and organization' do
    assessment(student, 4, today)
    outsider = create(:group)
    outside_subject = create(:subject)
    filtered = described_class.new(chapter:, today:, group_id: outsider.id, subject_id: outside_subject.id)

    expect(filtered.selected_group).to eq group
    expect(filtered.selected_subject).to eq subject
    expect(filtered.snapshot.first[:count]).to eq 1
  end

  it 'excludes deleted groups, subjects, skills and grade descriptors' do
    grade = assessment(student, 4, today)
    grade.grade_descriptor.update!(deleted_at: Time.current)
    expect(dashboard.activity[:students]).to eq [0, 0]
    skill.update!(deleted_at: Time.current)
    expect(dashboard.snapshot).to be_empty
    subject.update!(deleted_at: Time.current)
    expect(described_class.new(chapter:, today:).activity[:lessons]).to eq [0, 0]
    group.update!(deleted_at: Time.current)
    expect(described_class.new(chapter:, today:).groups).to be_empty
  end

  it 'rejects grades before enrollment starts and honors enrollment dates at a lesson boundary' do
    person = create(:student, organization:)
    create(:enrollment, student: person, group:, active_since: today - 1, inactive_since: today)
    assessment(person, 3, today - 2)
    assessment(person, 4, today)

    expect(dashboard.activity[:students]).to eq [1, 0]
    expect(dashboard.snapshot.first).to include(count: 0, average: nil)
  end

  it 'uses custom configured skill ranges instead of assuming a seven-point scale' do
    custom_skill = create(:skill, organization:)
    create(:assignment, subject:, skill: custom_skill)
    [10, 40, 70].each { |mark| create(:grade_descriptor, skill: custom_skill, mark:) }
    3.times { assessment(enrolled_student, 40, today, grade_skill: custom_skill) }

    entry = dashboard.snapshot.find { |row| row[:skill].id == custom_skill.id }
    expect(entry).to include(count: 3, average: 40.0, minimum: 10, maximum: 70)
  end

  it 'defaults to the group and subject of the most recent eligible assessment' do
    assessment(student, 3, today - 1)
    recent_group = create(:group, chapter:)
    recent_subject = create(:subject, organization:)
    create(:enrollment, student:, group: recent_group, active_since: today - 60)
    assessment(student, 4, today, lesson_group: recent_group, lesson_subject: recent_subject)

    expect(dashboard.selected_group).to eq recent_group
    expect(dashboard.selected_subject).to eq recent_subject
  end
end
