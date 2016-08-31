class Student < ActiveRecord::Base
  validates :first_name, :last_name, :dob, :gender, presence: true
  belongs_to :group
  enum gender: { male: 0, female: 1 }

  delegate :group_name, to: :group, allow_nil: true
end
