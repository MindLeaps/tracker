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

  describe '#edit' do
    before :each do
      @group = create :group

      get :edit, params: { id: @group.id }
    end

    it { should respond_with 200 }

    it 'presents a group to edit' do
      expect(assigns(:group)).to eq @group
    end
  end

  describe '#update' do
    before :each do
      @chapter1 = create :chapter
      @chapter2 = create :chapter
      @group = create :group, group_name: 'Test Group', chapter: @chapter1
    end

    context 'success' do
      before :each do
        post :update, params: { id: @group.id, group: { group_name: 'Updated Name', chapter_id: @chapter2.id } }
      end

      it { should respond_with 302 }

      it { should redirect_to group_url }

      it { should set_flash[:notice].to 'Group "Updated Name" successfully updated.' }

      it 'updates the edited group' do
        expect(@group.reload.group_name).to eq 'Updated Name'
        expect(@group.reload.chapter).to eq @chapter2
      end
    end

    context 'failure' do
      before :each do
        post :update, params: { id: @group.id, group: { group_name: '' } }
      end

      it { should respond_with 422 }
      it { should render_template :edit }
    end
  end
end
