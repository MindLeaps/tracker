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

  describe 'triggers' do
    before :each do
      @first_group = create :group
      @second_group = create :group, chapter: @first_group.chapter
      @student = create :student, group: @first_group
      @enrollment = create :enrollment, group: @first_group, student: @student
    end

    it 'the inactivity on student changing a group' do
      @student.update!(group: @second_group)

      expect(@enrollment.reload.inactive_since).to eq(Time.zone.today)
    end

    it 'a new enrollment on student changing a group' do
      @student.update!(group: @second_group)

      @new_enrollment = Enrollment.find_by(student: @student, group: @second_group)

      expect(@new_enrollment.active_since).to eq(Time.zone.today)
      expect(@new_enrollment.inactive_since).to be nil
    end
  end
end
