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
#  mlid                   :string(8)        not null
#  name_of_school         :string
#  notes                  :text
#  old_mlid               :string
#  quartier               :string
#  reason_for_leaving     :string
#  school_level_completed :string
#  year_of_dropout        :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  group_id               :integer
#  organization_id        :integer          not null
#  profile_image_id       :integer
#
# Indexes
#
#  index_students_on_group_id                  (group_id)
#  index_students_on_mlid_and_organization_id  (mlid,organization_id) UNIQUE
#  index_students_on_organization_id           (organization_id)
#  index_students_on_profile_image_id          (profile_image_id)
#
# Foreign Keys
#
#  fk_rails_...          (organization_id => organizations.id)
#  fk_rails_...          (profile_image_id => student_images.id)
#  students_group_id_fk  (group_id => groups.id)
#
class Student < ApplicationRecord
  require 'csv'
  include PgSearch::Model
  include Mlid
  pg_search_scope :search, against: [:first_name, :last_name, :mlid], associated_against: {
    tags: :tag_name
  }, using: { tsearch: { prefix: true } }

  validates :first_name, :last_name, :dob, :gender, presence: true
  validates :mlid, uniqueness: { scope: :organization_id }, length: { maximum: 8 }
  validate :group_belongs_to_same_organization

  enum :gender, { M: 'male', F: 'female', NB: 'nonbinary' }

  belongs_to :organization
  belongs_to :group
  has_many :grades, dependent: :restrict_with_error
  has_many :student_images, dependent: :restrict_with_error
  has_many :enrollments, dependent: :destroy
  belongs_to :profile_image, class_name: 'StudentImage', optional: true, inverse_of: :student
  has_many :student_tags, dependent: :destroy
  has_many :tags, through: :student_tags
  accepts_nested_attributes_for :grades
  accepts_nested_attributes_for :student_images
  accepts_nested_attributes_for :student_tags

  delegate :group_name, to: :group, allow_nil: true

  scope :by_group, ->(group_id) { where group_id: }

  def proper_name
    "#{last_name}, #{first_name}"
  end

  def age
    now = Time.now.utc.to_date
    now.year - dob.year - (now.month > dob.month || (now.month == dob.month && now.day >= dob.day) ? 0 : 1)
  end

  def to_export
    { id: id, first_name: first_name, last_name: last_name, date_of_birth: dob, age: age, country_of_nationality: country_of_nationality, gender: gender,
      group_id: group_id, group_name: group.group_name, enrolled_at: Enrollment.where(student_id: id, group_id: group_id).maximum(:active_since),
      total_average_score: StudentLessonSummary.where(student_id: id, group_id: group_id).average(:average_mark)&.round(2) || 'No scores yet' }
  end

  def self.permitted_params
    [:mlid, :first_name, :last_name, :dob, :estimated_dob, :group_id, :gender, :country_of_nationality, :quartier,
     :guardian_name, :guardian_occupation, :guardian_contact, :family_members, :health_insurance,
     :health_issues, :hiv_tested, :name_of_school, :school_level_completed, :year_of_dropout,
     :reason_for_leaving, :notes, :organization_id, :profile_image_id, { student_images_attributes: [:image], student_tags_attributes: [:tag_id, :student_id, :_destroy] }]
  end

  private

  def group_belongs_to_same_organization
    errors.add(:group, I18n.t(:student_and_group_in_different_organizations)) if group.present? && group.chapter.organization_id != organization_id
  end
end
