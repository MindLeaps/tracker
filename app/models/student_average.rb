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
class StudentAverage < ApplicationRecord
  def readonly?
    true
  end
end
