# == Schema Information
#
# Table name: temporary_summaries
#
#  country_of_nationality      :text
#  dob                         :date
#  first_group_lesson          :date
#  full_mlid                   :text
#  gender                      :enum
#  group_name                  :string
#  last_group_lesson           :date
#  lesson_average_mark         :decimal(, )
#  lesson_date                 :date
#  number_of_lessons_for_group :bigint
#  skill_marks                 :jsonb
#  group_id                    :integer
#  student_id                  :integer
#
class TemporarySummary < ApplicationRecord
  def self.to_csv(collection)
    CSV.generate(col_sep: ',') do |csv|
      # Define headers for exported attributes
      csv << [:full_mlid, :student_id, :age, :gender, :country_of_nationality, :group_id, :group_name,
              :mark, :skill_name, :lesson_date, :lesson_average_mark, :first_group_lesson, :last_group_lesson, :number_of_lessons_for_group
      ]
      collection.find_each do |record|
        csv << record.attributes.fetch_values('full_mlid', 'student_id', 'age', 'gender',
        'country_of_nationality', 'group_id', 'group_name', 'mark', 'skill_name', 'lesson_date', 'lesson_average_mark',
        'first_group_lesson', 'last_group_lesson', 'number_of_lessons_for_group')
      end
    end
  end

  def dob
    now = Time.now.utc.to_date
    now.year - dob.year - (now.month > dob.month || (now.month == dob.month && now.day >= dob.day) ? 0 : 1)
  end
end
