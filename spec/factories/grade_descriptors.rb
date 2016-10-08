FactoryGirl.define do
  factory :grade_descriptor do
    sequence(:mark) { |n| n }
    grade_description { Faker::Hipster.sentence }
    skill { create :skill }
  end
end
