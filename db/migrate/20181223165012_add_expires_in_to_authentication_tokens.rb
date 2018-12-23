# frozen_string_literal: true

class AddExpiresInToAuthenticationTokens < ActiveRecord::Migration[5.2]
  def change
    add_column :authentication_tokens, :expires_in, :integer
  end
end
