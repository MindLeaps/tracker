class Student < ActiveRecord::Base
  validates :first_name, :last_name, :dob, presence: true
end
