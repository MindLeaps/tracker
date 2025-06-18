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
#  old_group_id           :integer
#  organization_id        :integer          not null
#  profile_image_id       :integer
#
# Indexes
#
#  index_students_on_mlid_and_organization_id  (mlid,organization_id) UNIQUE
#  index_students_on_old_group_id              (old_group_id)
#  index_students_on_organization_id           (organization_id)
#  index_students_on_profile_image_id          (profile_image_id)
#
# Foreign Keys
#
#  fk_rails_...          (organization_id => organizations.id)
#  fk_rails_...          (profile_image_id => student_images.id)
#  students_group_id_fk  (old_group_id => groups.id)
#
class Student < ApplicationRecord
  require 'csv'
  include PgSearch::Model
  include Mlid
  pg_search_scope :search, against: [:first_name, :last_name, :mlid], associated_against: {
    tags: :tag_name,
    organization: :organization_name
  }, using: { tsearch: { prefix: true } }

  validates :first_name, :last_name, :dob, :gender, presence: true
  validates :mlid, uniqueness: { scope: :organization_id }, length: { maximum: 8 }
  validates_associated :enrollments
  validate :validate_organization_has_not_been_changed, on: :update

  enum :gender, { M: 'male', F: 'female', NB: 'nonbinary' }

  belongs_to :organization, inverse_of: :students
  has_many :grades, dependent: :restrict_with_error
  has_many :student_images, dependent: :restrict_with_error
  has_many :enrollments, inverse_of: :student, dependent: :destroy
  has_many :groups, through: :enrollments, inverse_of: :students
  belongs_to :profile_image, class_name: 'StudentImage', optional: true, inverse_of: :student
  has_many :student_tags, dependent: :destroy
  has_many :tags, through: :student_tags
  accepts_nested_attributes_for :grades
  accepts_nested_attributes_for :student_images
  accepts_nested_attributes_for :student_tags
  accepts_nested_attributes_for :enrollments, allow_destroy: true

  scope :by_group, ->(group_id) { includes(:enrollments).where(enrollments: { group_id: group_id }) }
  scope :by_organization, ->(organization_id) { where organization_id: }

  def proper_name
    "#{last_name}, #{first_name}"
  end

  def age
    now = Time.now.utc.to_date
    now.year - dob.year - (now.month > dob.month || (now.month == dob.month && now.day >= dob.day) ? 0 : 1)
  end

  def validate_organization_has_not_been_changed
    existing_student_organization = Student.find_by(id: id).organization
    errors.add :organization, I18n.t(:cannot_change_organization_existing_student) if existing_student_organization.id != organization.id
  end

  def deleted_enrollment_with_grades?
    enrollments.each do |enrollment|
      next unless enrollment.marked_for_destruction?

      lessons = Lesson.where(group_id: enrollment.group_id)
      grades = Grade.where(student_id: id, lesson_id: lessons, deleted_at: nil)

      return enrollment if grades.count.positive?
    end

    false
  end

  def updated_group_for_existing_enrollment?
    enrollments.each do |enrollment|
      original_enrollment = Enrollment.find_by(id: enrollment.id)

      return original_enrollment if original_enrollment.present? && original_enrollment.group_id != enrollment.group.id
    end

    false
  end

  def updated_enrollment_with_grades?
    enrollments.each do |enrollment|
      original_enrollment = Enrollment.find_by(id: enrollment.id)
      next if original_enrollment.blank?

      lessons = Lesson.where(group_id: original_enrollment.group_id)
      all_grades = Grade.where(student_id: id, lesson_id: lessons, deleted_at: nil)

      next unless enrollment.active_since != original_enrollment.active_since || enrollment.inactive_since != original_enrollment.inactive_since

      grades = Grade.where(student_id: id, lesson_id: lessons, deleted_at: nil, created_at: enrollment.active_since..enrollment.inactive_since)

      return original_enrollment if grades.count != all_grades.count
    end

    false
  end

  def to_export
    { id: id, first_name: first_name, last_name: last_name, date_of_birth: dob, age: age, country_of_nationality: country_of_nationality, gender: gender,
      organization_id: organization_id, enrolled_at: Enrollment.where(student_id: id, group_id: current_group_id).maximum(:active_since), group_id: current_group_id,
      group_name: Group.find(current_group_id).group_name, total_average_score: StudentLessonSummary.where(student_id: id, group_id: current_group_id).average(:average_mark)&.round(2) || 'No scores yet' }
  end

  def self.permitted_params
    [:mlid, :first_name, :last_name, :dob, :estimated_dob, :current_group_id, :old_group_id, :gender, :country_of_nationality, :quartier,
     :guardian_name, :guardian_occupation, :guardian_contact, :family_members, :health_insurance,
     :health_issues, :hiv_tested, :name_of_school, :school_level_completed, :year_of_dropout,
     :reason_for_leaving, :notes, :organization_id, :profile_image_id, { student_images_attributes: [:image], student_tags_attributes: [:tag_id, :student_id, :_destroy] },
     { enrollments_attributes: [:id, :student_id, :group_id, :active_since, :inactive_since, :_destroy] }]
  end
end
