# frozen_string_literal: true

# == Schema Information
#
# Table name: students
#
#  id                     :integer          not null, primary key
#  country_of_nationality :text
#  deleted_at             :datetime
#  dob                    :date             not null
#  estimated_dob          :boolean          default(TRUE), not null
#  family_members         :text
#  first_name             :string           not null
#  gender                 :enum             not null
#  guardian_contact       :string
#  guardian_name          :string
#  guardian_occupation    :string
#  health_insurance       :text
#  health_issues          :text
#  hiv_tested             :boolean
#  last_name              :string           not null
#  mlid                   :string           not null
#  name_of_school         :string
#  notes                  :text
#  quartier               :string
#  reason_for_leaving     :string
#  school_level_completed :string
#  year_of_dropout        :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  group_id               :integer
#  profile_image_id       :integer
#
# Indexes
#
#  index_students_on_group_id          (group_id)
#  index_students_on_profile_image_id  (profile_image_id)
#
# Foreign Keys
#
#  fk_rails_...          (profile_image_id => student_images.id)
#  students_group_id_fk  (group_id => groups.id)
#
class Student < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search, against: [:first_name, :last_name, :mlid], associated_against: {
    tags: :tag_name
  }, using: { tsearch: { prefix: true } }

  validates :mlid, :first_name, :last_name, :dob, :gender, presence: true
  validate :unique_mlid_in_chapter

  enum gender: { M: 'male', F: 'female' }

  belongs_to :group
  has_many :grades, dependent: :restrict_with_error
  has_many :absences, dependent: :restrict_with_error
  has_many :student_images, dependent: :restrict_with_error
  has_many :enrollments, dependent: :destroy
  belongs_to :profile_image, class_name: 'StudentImage', optional: true, inverse_of: :student
  has_many :student_tags, dependent: :destroy
  has_many :tags, through: :student_tags
  accepts_nested_attributes_for :grades
  accepts_nested_attributes_for :student_images
  accepts_nested_attributes_for :student_tags

  delegate :group_name, to: :group, allow_nil: true

  scope :by_group, ->(group_id) { where group_id: group_id }

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
     :reason_for_leaving, :notes, :organization_id, :profile_image_id, { student_images_attributes: [:image], student_tags_attributes: [:tag_id, :student_id, :_destroy] }]
  end

  private

  def unique_mlid_in_chapter
    if group.nil?
      errors.add(:mlid, I18n.t(:no_valid_mlid_without_group))
      return
    end
    existing_mlid_students = Student.where(mlid: mlid, group_id: group_id).where.not(id: id).count
    return if existing_mlid_students.zero?

    errors.add(:mlid, I18n.t(:duplicate_mlid))
  end
end
