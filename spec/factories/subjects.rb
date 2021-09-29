# frozen_string_literal: true

# == Schema Information
#
# Table name: subjects
#
#  id              :integer          not null, primary key
#  deleted_at      :datetime
#  subject_name    :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :integer          not null
#
# Indexes
#
#  index_subjects_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  subjects_organization_id_fk  (organization_id => organizations.id)
#
FactoryBot.define do
  factory :subject do
    sequence(:subject_name) { |n| "#{Faker::Educator.course_name}-#{n}" }
    organization { create :organization }
    transient do
      number_of_skills { 7 }
      skill_names { nil }
    end

    factory :subject_with_skills do
      after :create do |subject, evaluator|
        if evaluator.skill_names
          evaluator.skill_names.each { |name| create :skill_with_descriptors, subjects: [subject], organization: subject.organization, skill_name: name }
        else
          create_list(:skill, evaluator.number_of_skills, subjects: [subject], organization: subject.organization)
        end
      end
    end

    factory :subject_with_mindleaps_skills do
      after :create do |subject|
        create :skill_with_descriptors, skill_name: 'Memorization', subject: subject
        create :skill_with_descriptors, skill_name: 'Grit', subject: subject
        create :skill_with_descriptors, skill_name: 'Teamwork', subject: subject
        create :skill_with_descriptors, skill_name: 'Discipline', subject: subject
        create :skill_with_descriptors, skill_name: 'Self-Esteem', subject: subject
        create :skill_with_descriptors, skill_name: 'Creativity', subject: subject
        create :skill_with_descriptors, skill_name: 'Language', subject: subject
      end
    end
  end
end
