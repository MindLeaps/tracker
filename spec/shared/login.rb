RSpec.shared_context 'login' do
  before(:each) do
    visit '/'
    click_link 'Google Login'
  end
end
