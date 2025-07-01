# == Schema Information
#
# Table name: organizations
#
#  id                :integer          not null, primary key
#  country           :string
#  deleted_at        :datetime
#  image             :string           default("https://placeholdit.imgix.net/~text?txtsize=23&txt=200%C3%97200&w=200&h=200")
#  mlid              :string(3)        not null
#  organization_name :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  organizations_mlid_key  (mlid) UNIQUE
#
FactoryBot.define do
  factory :organization do
    sequence(:organization_name) { |n| "#{Faker::Company.name}-#{n}" }
    sequence(:mlid) { |n| n.to_s(36).rjust(3, '0').upcase }
  end
end
