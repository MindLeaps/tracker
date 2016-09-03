class User < ApplicationRecord
  devise :trackable, :omniauthable, omniauth_providers: [:google_oauth2]
  def self.from_omniauth(auth)
    user_record = where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.uid = auth['uid']
      user.name = auth['info']['name']
      user.email = auth['info']['email']
    end
    user_record.update image: auth['info']['image']
    user_record
  end
end
