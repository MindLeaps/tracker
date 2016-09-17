FactoryGirl.define do
  factory :lesson do
    date { Faker::Time.between Time.zone.today, 5.days.ago }
    group { create :group }
    subject { create :subject }
  end
end
