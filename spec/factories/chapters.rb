FactoryGirl.define do
  factory :chapter do
    sequence(:chapter_name) { |n| "#{Faker::StarWars.planet}-#{n}" }
  end
end
