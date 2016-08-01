require 'rails_helper'

RSpec.describe GroupsController, type: :controller do
  fixtures :groups

  before(:each) do
    allow(controller).to receive(:current_user)
      .and_return(instance_double 'User', name: 'User For Testing', uid: '000000000000')
  end

  describe '#new' do
    it 'create a group when supplied valid params' do
      post :create, params: { group: { group_name: 'Group A' } }
      expect(response).to redirect_to controller: :groups, action: :index

      group = Group.last
      expect(group.group_name).to eql 'Group A'
    end
  end

  describe '#index' do
    it 'gets a list of groups' do
      get :index
      expect(response).to be_success

      expect(assigns(:groups)).to include groups(:group_a)
    end
  end
end
