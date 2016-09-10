FactoryGirl.define do
  factory :chapter do
    chapter_name { Faker::StarWars.planet }
  end
end
