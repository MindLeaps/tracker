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
class StudentSerializer < ActiveModel::Serializer
  attributes :mlid, :id, :first_name, :last_name, :dob, :estimated_dob, :gender, :quartier, :guardian_name, :guardian_occupation,
             :guardian_contact, :family_members, :health_insurance, :health_issues, :hiv_tested, :name_of_school, :school_level_completed,
             :year_of_dropout, :reason_for_leaving, :notes, :deleted_at

  has_many :enrollments, inverse_of: :student, dependent: :destroy
  belongs_to :organization
end
