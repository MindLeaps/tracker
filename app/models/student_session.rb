class StudentSession < ActiveRecord::Base
  belongs_to :student
  belongs_to :session
end
