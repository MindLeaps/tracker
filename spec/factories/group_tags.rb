FactoryBot.define do
  factory :group_tag do
    group { create :group }
    tag { create :tag }
  end
end
