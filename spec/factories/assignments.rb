# frozen_string_literal: true

FactoryGirl.define do
  factory :assignment do
    subject { create :subject }
    skill { create :skill }
  end
end
