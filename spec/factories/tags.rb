# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id              :uuid             not null, primary key
#  shared          :boolean          not null
#  tag_name        :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :bigint           not null
#
# Indexes
#
#  index_tags_on_organization_id  (organization_id)
#
FactoryBot.define do
  factory :tag do
    tag_name { Faker::Games::Pokemon.name }
    organization { create :organization }
    shared { true }
  end
end
