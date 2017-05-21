# frozen_string_literal: true

FactoryGirl.define do
  factory :user do
    name 'Test User'
    email { Faker::Internet.safe_email }
    sequence(:uid) { |n| n }
    provider 'google_oauth2'
    transient do
      organization nil
      token nil
    end
    after(:create) { |user| user.update_role :user }

    factory :admin do
      after(:create) { |user| user.update_role :admin }
    end

    factory :super_admin do
      after(:create) { |user| user.update_role :super_admin }
    end

    factory :admin_of do
      after(:create) { |user, evaluator| user.add_role :admin, evaluator.organization }
    end
  end
end
