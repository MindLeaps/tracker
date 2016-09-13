class Student < ActiveRecord::Base
  validates :first_name, :last_name, :dob, :gender, :organization, presence: true
  belongs_to :group
  belongs_to :organization
  enum gender: { M: 0, F: 1 }

  delegate :group_name, to: :group, allow_nil: true

  def self.permitted_params
    [:first_name, :last_name, :dob, :estimated_dob, :group_id, :gender, :quartier,
     :guardian_name, :guardian_occupation, :guardian_contact, :family_members, :health_insurance,
     :health_issues, :hiv_tested, :name_of_school, :school_level_completed, :year_of_dropout,
     :reason_for_leaving, :notes, :organization_id]
  end
end
