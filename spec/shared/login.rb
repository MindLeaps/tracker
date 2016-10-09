# frozen_string_literal: true
require 'rails_helper'

RSpec.shared_context 'login_with_admin' do
  before(:each) do
    login create :admin
  end
end

RSpec.shared_context 'login_with_super_admin' do
  before(:each) do
    login create :super_admin
  end
end
