# frozen_string_literal: true

class EnableUuid < ActiveRecord::Migration[5.2]
  def change
    enable_extension 'uuid-ossp'
  end
end
