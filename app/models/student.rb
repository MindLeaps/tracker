class Student < ActiveRecord::Base
  validates :first_name, :last_name, :dob, :gender, presence: true
  belongs_to :group
  enum gender: { M: 0, F: 1 }

  delegate :group_name, to: :group, allow_nil: true

  def self.permitted_params
    [:first_name, :last_name, :dob, :estimated_dob, :group_id, :gender, :quartier,
     :health_insurance, :health_issues, :hiv_tested, :name_of_school, :school_level_completed,
     :year_of_dropout, :reason_for_leaving, :notes]
  end
end
