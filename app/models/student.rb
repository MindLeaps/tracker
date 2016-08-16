class Student < ActiveRecord::Base
  belongs_to :group
  has_many :student_sessions
  has_many :sessions, through: :student_sessions
  has_many :grades, through: :student_sessions

  validates :first_name, :last_name, :dob, presence: true

  delegate :group_name, to: :group, allow_nil: true

  def current_session
    sessions.last || sessions.build
  end
end
