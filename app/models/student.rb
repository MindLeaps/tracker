class Student < ActiveRecord::Base
  validates :first_name, :last_name, :dob, presence: true
  belongs_to :group
  delegate :group_name, to: :group, allow_nil: true
end
