# == Schema Information
#
# Table name: countries
#
#  id           :bigint           not null, primary key
#  country_name :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
FactoryBot.define do
  factory :country do
    sequence(:country_name) { |n| "#{Faker::Nation.name}-#{n}" }
  end
end
