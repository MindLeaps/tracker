# == Schema Information
#
# Table name: performance_per_group_per_skill_per_lessons
#
#  date               :date
#  group_chapter_name :text
#  group_name         :string
#  mark               :float
#  skill_name         :string
#  group_id           :integer
#  lesson_id          :uuid
#  skill_id           :integer
#  subject_id         :integer
#
require 'rails_helper'

RSpec.describe PerformancePerGroupPerSkillPerLesson, type: :model do
  before :each do
    @org = create :organization
    @chapter = create :chapter, organization: @org
    @group1 = create :group, chapter: @chapter
    @group2 = create :group, chapter: @chapter
  end
  it 'calculates performance per group per skill per lesson' do
    subject = create :subject_with_skills, skill_names: %w[Memorization Grit], organization: @org

    create :graded_student, subject:, organization: @org, groups: [@group1], grades: {
      'Memorization' => [7, 5, 4], 'Grit' => [3, 2, 5]
    }

    create :graded_student, subject:, organization: @org, groups: [@group1], grades: {
      'Memorization' => [1, 3, 4], 'Grit' => [1, 2, 1]
    }

    create :graded_student, subject:, organization: @org, groups: [@group2], grades: {
      'Memorization' => [1, 3, 6], 'Grit' => [2, 4, 7]
    }

    create :graded_student, subject:, organization: @org, groups: [@group2], grades: {
      'Memorization' => [1, 5, 6], 'Grit' => [2, 6, 7]
    }

    results = PerformancePerGroupPerSkillPerLesson.all
    expect(results.size).to eq 12

    expect(PerformancePerGroupPerSkillPerLesson.where(skill_name: 'Memorization', group: @group1).map(&:mark)).to eq [4.0, 4.0, 4.0]
    expect(PerformancePerGroupPerSkillPerLesson.where(skill_name: 'Grit', group: @group1).map(&:mark)).to eq [2.0, 2.0, 3.0]
    expect(PerformancePerGroupPerSkillPerLesson.where(skill_name: 'Memorization', group: @group2).map(&:mark)).to eq [1.0, 4.0, 6.0]
    expect(PerformancePerGroupPerSkillPerLesson.where(skill_name: 'Grit', group: @group2).map(&:mark)).to eq [2.0, 5.0, 7.0]
  end
end
