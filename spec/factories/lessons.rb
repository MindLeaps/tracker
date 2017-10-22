# frozen_string_literal: true

FactoryBot.define do
  factory :lesson do
    sequence(:date) { |n| n.days.ago }
    group { create :group }
    subject { create :subject }
  end
end
