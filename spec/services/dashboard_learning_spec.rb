require 'rails_helper'

RSpec.describe DashboardLearning do
  let(:today) { Date.current }

  def rows(student_id, marks, last_date = today)
    marks.each_with_index.map do |mark, index|
      { student_id:, group_id: 1, subject_id: 1, skill_id: 1, position: 3 - index, mark:, lesson_date: last_date - (2 - index) }
    end
  end

  it 'does not flag plateaus, reversals or fewer than three assessments' do
    data = rows(1, [6, 6, 3]) + rows(2, [1, 5, 3]) + rows(3, [6, 5])
    learning = described_class.new(rows: data, week: (today - 6)..today)
    expect(learning.patterns(:decline, 5)).to be_empty
    expect(learning.patterns(:improvement, 3)).to be_empty
  end

  it 'sorts equal changes by recency and limits progress highlights to three students' do
    data = rows(1, [1, 2, 3], today - 1) + rows(2, [1, 2, 3]) + rows(3, [1, 2, 5]) + rows(4, [1, 2, 3], today - 2)
    learning = described_class.new(rows: data, week: (today - 6)..today)
    expect(learning.patterns(:improvement, 3).pluck(:student_id)).to eq [3, 2, 1]
  end
end
