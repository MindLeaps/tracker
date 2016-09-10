FactoryGirl.define do
  factory :user do
    name 'Test User'
    email { Faker::Internet.safe_email }
    sequence(:uid) { |n| n }
    provider 'google_oauth2'

    factory :admin do
      after(:create) { |user| user.add_role :admin }
    end

    factory :super_admin do
      after(:create) { |user| user.add_role :super_admin }
    end
  end
end