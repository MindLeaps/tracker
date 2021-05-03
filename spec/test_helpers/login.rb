# frozen_string_literal: true

module Helpers
  def login(user)
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: user.provider,
      uid: user.uid,
      info: { name: user.name, email: user.email }
    )
    visit '/'
    click_button 'Sign in with Google'
  end
end
