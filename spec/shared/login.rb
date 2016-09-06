RSpec.shared_context 'login' do
  fixtures :users
  before(:each) do
    @mock_user = users(:teacher_one)
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: @mock_user.provider,
      uid: @mock_user.uid,
      info: { name: @mock_user.name, email: @mock_user.email }
    )
    visit '/'
    click_link 'Google Login'
  end
end

RSpec.shared_context 'login_super_admin' do
  fixtures :users
  before(:each) do
    @mock_user = users(:super_admin_one)
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: @mock_user.provider,
      uid: @mock_user.uid,
      info: { name: @mock_user.name, email: @mock_user.email }
    )
    visit '/'
    click_link 'Google Login'
  end
end

RSpec.shared_context 'controller_login' do
  fixtures :users
  before(:each) do
    sign_in users(:teacher_one)
  end
end

RSpec.shared_context 'controller_login_super_admin' do
  fixtures :users
  before(:each) do
    sign_in users(:super_admin_one)
  end
end
