# frozen_string_literal: true

FactoryGirl.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.safe_email }
    sequence(:uid) { |n| n }
    provider 'google_oauth2'
    transient do
      organization nil
      token nil
    end

    factory :global_guest do
      after(:create) { |user| user.update_role :global_guest }
    end

    factory :global_admin do
      after(:create) { |user| user.update_role :global_admin }
    end

    factory :super_admin do
      after(:create) { |user| user.update_role :super_admin }
    end

    factory :admin_of do
      after(:create) { |user, evaluator| user.add_role :admin, evaluator.organization }
    end

    factory :teacher_in do
      after(:create) { |user, evaluator| user.add_role :teacher, evaluator.organization }
    end
  end
end
