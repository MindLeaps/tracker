FactoryGirl.define do
  factory :organization do
    organization_name { Faker::Company.name }
  end
end