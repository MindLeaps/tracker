# == Schema Information
#
# Table name: country_summaries
#
#  id                 :bigint           primary key
#  country_name       :string
#  organization_count :bigint
#
class CountrySummary < ApplicationRecord
  include PgSearch::Model
  self.primary_key = :id
  pg_search_scope :search, against: [:country_name], using: { tsearch: { prefix: true } }

  def readonly?
    true
  end

  def self.policy_class
    CountryPolicy
  end
end
