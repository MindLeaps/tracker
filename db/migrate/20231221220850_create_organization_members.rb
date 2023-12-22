# frozen_string_literal: true

class CreateOrganizationMembers < ActiveRecord::Migration[7.0]
  def change
    create_view :organization_members
  end
end
