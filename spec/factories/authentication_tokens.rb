# == Schema Information
#
# Table name: authentication_tokens
#
#  id           :integer          not null, primary key
#  body         :string
#  expires_in   :integer
#  ip_address   :string
#  last_used_at :datetime
#  user_agent   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :integer
#
# Indexes
#
#  index_authentication_tokens_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :authentication_token do
    body { Faker::Code.ean }
    user_agent { 'Rails Testing' }
    user
  end
end
