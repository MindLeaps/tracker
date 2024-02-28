# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  current_sign_in_at :datetime
#  current_sign_in_ip :string
#  email              :string           default(""), not null
#  image              :string
#  last_sign_in_at    :datetime
#  last_sign_in_ip    :string
#  name               :string
#  provider           :string
#  sign_in_count      :integer          default(0), not null
#  uid                :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    sequence(:uid) { |n| n }
    provider { 'google_oauth2' }
    transient do
      role { nil }
      organization { nil }
      token { nil }
    end

    factory :global_guest do
      after(:create) { |user| user.add_role :global_guest }
    end

    factory :global_researcher do
      after(:create) { |user| user.add_role :global_researcher }
    end

    factory :global_admin do
      after(:create) { |user| user.add_role :global_admin }
    end

    factory :super_admin do
      after(:create) { |user| user.add_role :super_admin }
    end

    factory :admin_of do
      after(:create) { |user, evaluator| evaluator.organization && user.add_role(:admin, evaluator.organization) }
    end

    factory :teacher_in do
      after(:create) { |user, evaluator| evaluator.organization && user.add_role(:teacher, evaluator.organization) }
    end

    factory :guest_in do
      after(:create) { |user, evaluator| evaluator.organization && user.add_role(:guest, evaluator.organization) }
    end

    factory :researcher_in do
      after(:create) { |user, evaluator| evaluator.organization && user.add_role(:researcher, evaluator.organization) }
    end

    factory :user_with_role do
      after(:create) { |user, evaluator| evaluator.role && user.add_role(evaluator.role, evaluator.organization) }
    end

    factory :user_with_global_role do
      after(:create) { |user, evaluator| evaluator.role && user.add_role(evaluator.role) }
    end
  end
end
