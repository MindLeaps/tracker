require 'rails_helper'

RSpec.describe GroupsController, type: :controller do
  fixtures :groups, :chapters
  include_context 'controller_login'

  describe '#new' do
    it 'create a group when supplied valid params' do
      post :create, params: { group: { group_name: 'New Test Group',
                                       chapter_id: chapters(:kigali_chapter).id } }
      expect(response).to redirect_to controller: :groups, action: :index

      group = Group.last
      expect(group.group_name).to eql 'New Test Group'
      expect(group.chapter.chapter_name).to eql chapters(:kigali_chapter).chapter_name
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
