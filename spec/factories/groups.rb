FactoryGirl.define do
  factory :group do
    group_name { Faker::StarWars.vehicle }
  end
end
