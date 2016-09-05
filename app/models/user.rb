class User < ApplicationRecord
  devise :trackable, :omniauthable, omniauth_providers: [:google_oauth2]
  def self.from_omniauth(auth)
    if User.exists?(email: auth['info']['email']) || User.count.zero?
      return update_user_from_omniauth User.find_by(email: auth['info']['email']), auth
    end
    empty_user
  end

  def self.update_user_from_omniauth(user, auth)
    user.update(
      uid: auth['uid'],
      name: auth['info']['name'],
      email: auth['info']['email'],
      provider: auth.provider,
      image: auth['info']['image']
    )
    user
  end

  def self.empty_user
    User.new
  end
end
