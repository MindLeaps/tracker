# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_context 'login_with_global_admin' do
  before(:each) do
    login create :global_admin
  end
end

RSpec.shared_context 'login_with_super_admin' do
  before(:each) do
    login create :super_admin
  end
end

RSpec.shared_context 'super_admin_request' do
  before(:each) do
    @current_user = create :super_admin
    @token = Tiddle.create_and_return_token(@current_user, instance_double('Request', remote_ip: '127.0.0.1', user_agent: 'Test'))
  end
end
