FactoryGirl.define do
  factory :subject do
    sequence(:subject_name) { |n| "#{Faker::Educator.course}-#{n}" }
    organization { create :organization }
  end
end
