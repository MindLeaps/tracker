# frozen_string_literal: true

# == Schema Information
#
# Table name: organization_members
#
#  id                 :integer          primary key
#  current_sign_in_at :datetime
#  current_sign_in_ip :string
#  email              :string
#  global_role        :string
#  image              :string
#  last_sign_in_at    :datetime
#  last_sign_in_ip    :string
#  local_role         :string
#  name               :string
#  provider           :string
#  sign_in_count      :integer
#  uid                :string
#  created_at         :datetime
#  updated_at         :datetime
#  organization_id    :integer
#
class OrganizationMember < ApplicationRecord
  self.primary_key = :id
  singleton_class.send(:alias_method, :table_order_members, :table_order)
  def readonly?
    true
  end
end
