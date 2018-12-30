# frozen_string_literal: true

class StudentSerializer < ActiveModel::Serializer
  attributes :mlid, :id, :first_name, :last_name, :dob, :estimated_dob, :group_id, :gender, :quartier, :guardian_name, :guardian_occupation,
             :guardian_contact, :family_members, :health_insurance, :health_issues, :hiv_tested, :name_of_school, :school_level_completed,
             :year_of_dropout, :reason_for_leaving, :notes, :deleted_at

  belongs_to :group
  belongs_to :organization
end
