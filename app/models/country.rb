# == Schema Information
#
# Table name: countries
#
#  id           :bigint           not null, primary key
#  country_name :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Country < ApplicationRecord
  include PgSearch::Model
  validates :country_name, presence: true, uniqueness: true

  has_one :organization, dependent: :nullify
end
