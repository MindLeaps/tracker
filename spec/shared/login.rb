RSpec.shared_context 'login' do
  before(:each) do
    visit '/'
    click_link 'Google Login'
  end
end

RSpec.shared_context 'controller_login' do
  before(:each) do
    allow(controller).to receive(:current_user)
      .and_return(instance_double('User', name: 'User For Testing', uid: '000000000000'))
  end
end
