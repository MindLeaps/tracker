# == Schema Information
#
# Table name: student_averages
#
#  average_mark       :decimal(, )
#  first_name         :string
#  last_name          :string
#  skill_name         :string
#  student_deleted_at :datetime
#  subject_name       :string
#  student_id         :integer
#  subject_id         :integer
#
require 'rails_helper'

RSpec.describe StudentAverage, type: :model do
  describe 'Averages calculation' do
    context 'student that has been graded' do
      before :each do
        @student = create :graded_student, grades: {
          'Memorization' => [1],
          'Grit' => [1, 2],
          'Teamwork' => [3, 4, 4]
        }
      end
      it 'returns the skills for which the student has been graded on' do
        skill_averages = StudentAverage.where(student_id: @student.id)
        expect(skill_averages.length).to eq(3)
        expect(skill_averages.map(&:skill_name)).to contain_exactly('Memorization', 'Grit', 'Teamwork')
      end
      it 'calculates the average marks correctly' do
        skill_averages = StudentAverage.where(student_id: @student.id).order(skill_name: :asc).map(&:average_mark)
        expect(skill_averages[0]).to be_within(0.01).of 1.5
        expect(skill_averages[1]).to be_within(0.01).of 1.0
        expect(skill_averages[2]).to be_within(0.01).of 3.66
      end
    end
  end
end
