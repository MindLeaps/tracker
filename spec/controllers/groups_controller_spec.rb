# frozen_string_literal: true
require 'rails_helper'

RSpec.describe GroupsController, type: :controller do
  let(:admin) { create :admin }
  let(:kigali_chapter) { create :chapter, chapter_name: 'Newly Created Test Chapter' }

  before :each do
    sign_in admin
  end

  describe '#new' do
    it 'create a group when supplied valid params' do
      post :create, params: { group: { group_name: 'New Test Group',
                                       chapter_id: kigali_chapter.id } }
      expect(response).to redirect_to controller: :groups, action: :index

      group = Group.last
      expect(group.group_name).to eql 'New Test Group'
      expect(group.chapter.chapter_name).to eql 'Newly Created Test Chapter'
    end
  end

  describe '#index' do
    it 'gets a list of groups' do
      group1 = create :group
      group2 = create :group

      get :index

      expect(response).to be_success
      expect(assigns(:groups)).to include group1
      expect(assigns(:groups)).to include group2
    end
  end
end
