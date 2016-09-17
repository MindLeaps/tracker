FactoryGirl.define do
  factory :skill do
    organization { create :organization }
    sequence(:skill_name) { |n| "#{Faker::Hipster.word}-#{n}" }
  end
end
