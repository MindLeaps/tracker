class Student < ActiveRecord::Base
  validates :first_name, :last_name, :dob, :gender, presence: true
  belongs_to :group
  enum gender: { M: 0, F: 1 }

  delegate :group_name, to: :group, allow_nil: true

  def self.permitted_params
    [:first_name, :last_name, :dob, :estimated_dob, :group_id, :gender, :quartier,
     :health_insurance, :health_issues, :hiv_tested]
  end
end
