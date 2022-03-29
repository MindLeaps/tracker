# frozen_string_literal: true

# == Schema Information
#
# Table name: student_tag_table_rows
#
#  id                :uuid             primary key
#  organization_name :string
#  shared            :boolean
#  student_count     :bigint
#  tag_name          :string
#  organization_id   :integer
#
class StudentTagTableRow < ApplicationRecord
  belongs_to :organization

  def policy_class
    TagPolicy
  end

  include PgSearch::Model
  pg_search_scope :search, against: [:tag_name, :organization_name], using: { tsearch: { prefix: true } }

  self.primary_key = :id

  def readonly?
    true
  end
end
