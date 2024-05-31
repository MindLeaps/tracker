# == Schema Information
#
# Table name: skills
#
#  id                :integer          not null, primary key
#  deleted_at        :datetime
#  skill_description :text
#  skill_name        :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  organization_id   :integer          not null
#
# Indexes
#
#  index_skills_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  skills_organization_id_fk  (organization_id => organizations.id)
#
FactoryBot.define do
  factory :skill do
    organization { create :organization }
    sequence(:skill_name) { |n| "#{Faker::Music.instrument}-#{n}" }
    sequence(:skill_description) { |n| "#{Faker::Lorem.sentence}-#{n}" }
    transient do
      subject { nil }
    end


    factory :skill_in_subject do
      after(:create) do |skill, evaluator|
        subject = evaluator.subject || create(:subject)
        create :assignment, skill:, subject:
      end

      factory :skill_with_descriptors do
        after(:create) do |skill|
          (1..7).each { |mark| create :grade_descriptor, mark:, skill: }
        end
      end
    end

    factory :skill_removed_from_subject do
      after(:create) do |skill, evaluator|
        subject = evaluator.subject || create(:subject)
        create :assignment, skill:, subject:, deleted_at: Time.zone.now
      end
    end
  end
end
