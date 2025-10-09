# == Schema Information
#
# Table name: student_analytics_summaries
#
#  id                 :integer          primary key
#  enrolled_group_ids :bigint           is an Array
#  first_name         :string
#  last_name          :string
#  old_group_id       :integer
#
class StudentAnalyticsSummary < ApplicationRecord
  self.table_name = 'student_analytics_summaries'
  self.primary_key = 'id'

  def proper_name
    "#{last_name}, #{first_name}"
  end
end
