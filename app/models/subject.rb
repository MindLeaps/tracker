# frozen_string_literal: true
class Subject < ActiveRecord::Base
  belongs_to :organization
  has_many :lessons
  has_many :assignments, inverse_of: :subject, dependent: :destroy
  has_many :skills, through: :assignments

  validates :subject_name, :organization, presence: true

  accepts_nested_attributes_for :assignments
end
