# == Schema Information
#
# Table name: student_table_rows
#
#  id                     :integer          primary key
#  chapter_mlid           :string(2)
#  country_of_nationality :text
#  deleted_at             :datetime
#  dob                    :date
#  estimated_dob          :boolean
#  family_members         :text
#  first_name             :string
#  full_mlid              :text
#  gender                 :enum
#  group_mlid             :string(2)
#  group_name             :string
#  guardian_contact       :string
#  guardian_name          :string
#  guardian_occupation    :string
#  health_insurance       :text
#  health_issues          :text
#  hiv_tested             :boolean
#  last_name              :string
#  mlid                   :string(8)
#  name_of_school         :string
#  notes                  :text
#  old_mlid               :string
#  organization_mlid      :string(3)
#  quartier               :string
#  reason_for_leaving     :string
#  school_level_completed :string
#  year_of_dropout        :integer
#  created_at             :datetime
#  updated_at             :datetime
#  old_group_id           :integer
#  organization_id        :integer
#  profile_image_id       :integer
#
class StudentTableRow < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search, against: [:first_name, :last_name, :full_mlid], associated_against: {
    tags: :tag_name,
    organization: :organization_name
  }, using: { tsearch: { prefix: true } }

  self.primary_key = :id
  belongs_to :group
  belongs_to :organization
  has_many :student_tags, foreign_key: :student_id, inverse_of: :student, dependent: :restrict_with_exception
  has_many :tags, through: :student_tags
  scope :by_group, ->(group_id) { where group_id: }

  enum :gender, { M: 'male', F: 'female', NB: 'nonbinary' }

  def readonly?
    true
  end

  def self.policy_class
    StudentPolicy
  end
end
