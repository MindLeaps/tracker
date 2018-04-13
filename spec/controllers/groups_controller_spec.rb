# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupsController, type: :controller do
  let(:admin) { create :global_admin }
  let(:kigali_chapter) { create :chapter, chapter_name: 'Newly Created Test Chapter' }

  before :each do
    sign_in admin
  end

  describe '#new' do
    before :each do
      get :new
    end

    it { should respond_with 200 }
    it { should render_template 'new' }
    it 'assigns the new empty group' do
      expect(assigns(:group)).to be_kind_of(Group)
    end
  end

  describe '#create' do
    context 'valid group data' do
      before :each do
        post :create, params: { group: { group_name: 'New Test Group',
                                         chapter_id: kigali_chapter.id } }
      end

      it 'creates a new group' do
        group = Group.last
        expect(group.group_name).to eql 'New Test Group'
        expect(group.chapter.chapter_name).to eql 'Newly Created Test Chapter'
      end

      it { should respond_with 302 }
      it { should redirect_to group_path(assigns[:group]) }
    end

    context 'invalid group data' do
      before :each do
        post :create, params: { group: { chapter_id: kigali_chapter.id } }
      end

      it { should render_template :new }
    end
  end

  describe '#index' do
    before :each do
      @groups = create_list :group, 3
      @deleted_group = create :group, deleted_at: 1.second.ago

      get :index
    end

    it 'gets a list of groups' do
      expect(response).to be_successful
      expect(assigns(:groups).length).to eq 3
      expect(assigns(:groups)).to include(*@groups)
    end

    it 'does not include deleted groups' do
      expect(assigns(:groups)).not_to include @deleted_group
    end

    it 'includes deleted groups' do
      get :index, params: { exclude_deleted: false }

      expect(assigns(:groups).length).to eq 4
      expect(assigns(:groups)).to include @deleted_group
    end
  end

  describe '#show' do
    before :each do
      @group = create :group
      @student1 = create :student, group: @group
      @student2 = create :student, group: @group
      @deleted_student = create :student, group: @group, deleted_at: Time.zone.now

      get :show, params: { id: @group.id }
    end

    it { should respond_with 200 }

    it { should render_template :show }

    it 'exposes current group' do
      expect(assigns(:group)).to eq @group
    end

    it 'exposes non-deleted students in a group' do
      expect(assigns(:students)).to include @student1, @student2
      expect(assigns(:students)).not_to include @deleted_student
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

      it { should set_flash[:notice].to 'Group "Updated Name" updated.' }

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

  describe '#destroy' do
    before :each do
      @group = create :group

      @students = create_list :student, 2, group: @group

      post :destroy, params: { id: @group.id }
    end

    it { should redirect_to groups_path }

    it { should set_flash[:undo_notice] }

    it 'Marks the group as deleted' do
      expect(@group.reload.deleted_at).to be_within(1.second).of Time.zone.now
    end
  end

  describe '#undelete' do
    before :each do
      @group = create :group, deleted_at: Time.zone.now

      post :undelete, params: { id: @group.id }
    end

    it { should redirect_to groups_path }

    it { should set_flash[:notice].to "Group \"#{@group.group_name}\" restored." }

    it 'Removes the group\'s deleted timestamp' do
      expect(@group.reload.deleted_at).to be_nil
    end
  end
end
