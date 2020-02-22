# frozen_string_literal: true

class Student < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search, against: [:first_name, :last_name, :mlid], using: { tsearch: { prefix: true } }

  validates :mlid, :first_name, :last_name, :dob, :gender, :group, presence: true
  validates :mlid, uniqueness: true
  validate :profile_image_belongs_to_student, if: proc { |student| !student.profile_image.nil? }

  enum gender: { M: 'male', F: 'female' }

  belongs_to :group
  has_many :grades, dependent: :restrict_with_error
  has_many :absences, dependent: :restrict_with_error
  has_many :student_images, dependent: :restrict_with_error
  belongs_to :profile_image, class_name: 'StudentImage', optional: true, inverse_of: :student
  accepts_nested_attributes_for :grades
  accepts_nested_attributes_for :student_images

  delegate :group_name, to: :group, allow_nil: true

  scope :by_group, ->(group_id) { where group_id: group_id }

  scope :order_by_group_name, ->(sorting) { joins(:group).order("groups.group_name #{sorting == 'desc' ? 'DESC' : 'ASC'}") }

  def proper_name
    "#{last_name}, #{first_name}"
  end

  def organization
    Organization.joins(chapters: :groups).find_by('groups.id = ?', group_id)
  end

  def self.permitted_params
    [:mlid, :first_name, :last_name, :dob, :estimated_dob, :group_id, :gender, :country_of_nationality, :quartier,
     :guardian_name, :guardian_occupation, :guardian_contact, :family_members, :health_insurance,
     :health_issues, :hiv_tested, :name_of_school, :school_level_completed, :year_of_dropout,
     :reason_for_leaving, :notes, :organization_id, :profile_image_id, student_images_attributes: [:image]]
  end

  private

  def profile_image_belongs_to_student
    errors.add(:profile_image, I18n.t(:wrong_image, student: proper_name, other_student: profile_image.student.proper_name)) if profile_image.student.id != id
  end
end
