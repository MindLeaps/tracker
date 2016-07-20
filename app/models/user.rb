class User < ApplicationRecord
  def self.from_omniauth(auth)
    find_by(auth.slice('uid')) || create_from_omniauth(auth)
  end

  def self.create_from_omniauth(auth)
    create! do |user|
      user.uid = auth['uid']
      user.name = auth['info']['name']
    end
  end
end
