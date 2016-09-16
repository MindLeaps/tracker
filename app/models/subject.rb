class Subject < ActiveRecord::Base
  belongs_to :organization

  validates :subject_name, :organization, presence: true
end
