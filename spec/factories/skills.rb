FactoryGirl.define do
  factory :skill do
    organization { create :organization }
    sequence(:skill_name) { |n| "#{Faker::Hipster.word}-#{n}" }
    transient do
      subject nil
    end

    factory :skill_in_subject do
      after(:create) do |skill, evaluator|
        subject = evaluator.subject || create(:subject)
        create :assignment, skill: skill, subject: subject
      end
    end
  end
end
