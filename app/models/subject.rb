class Subject < ActiveRecord::Base
  belongs_to :organization
  has_many :lessons

  validates :subject_name, :organization, presence: true
end
