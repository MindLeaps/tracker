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

    it 'prepopulates the group with the correct chapter' do
      chapter = create :chapter
      get :new, params: { chapter_id: chapter.id }

      expect(assigns(:group).chapter.id).to eq chapter.id
      expect(assigns(:group).chapter.chapter_name).to eq chapter.chapter_name
    end
  end

  describe '#create' do
    context 'valid group data' do
      before :each do
        post :create, params: { group: { group_name: 'New Test Group',
                                         mlid: 'G0',
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
      @group1 = create :group, group_name: 'Dumbator'
      @group2 = create :group, group_name: 'Albator'
      @group3 = create :group, group_name: 'Albion'
      @deleted_group = create :group, deleted_at: 1.second.ago, group_name: 'Albaritor'
    end

    context 'regular visit' do
      before :each do
        get :index
      end

      it 'gets a list of groups' do
        expect(response).to be_successful
        expect(assigns(:groups).length).to eq 3
        expect(assigns(:groups)).to include GroupSummary.find(@group1.id), GroupSummary.find(@group2.id), GroupSummary.find(@group3.id)
      end

      it 'does not include deleted groups' do
        expect(assigns(:groups)).not_to include GroupSummary.find(@deleted_group.id)
      end

      it 'includes deleted groups' do
        get :index, params: { exclude_deleted: false }

        expect(assigns(:groups).length).to eq 4
        expect(assigns(:groups)).to include GroupSummary.find(@deleted_group.id)
      end
    end

    context 'searching for a group' do
      before :each do
        get :index, params: { search: 'Alb' }
      end

      it { should respond_with 200 }

      it 'assigns searched groups' do
        expect(assigns(:groups).length).to eq 2
        expect(assigns(:groups)).to include GroupSummary.find(@group2.id), GroupSummary.find(@group3.id)
      end

      it 'includes deleted groups' do
        get :index, params: { search: 'Alb', exclude_deleted: false }
        expect(assigns(:groups).length).to eq 3
        expect(assigns(:groups)).to include GroupSummary.find(@group2.id), GroupSummary.find(@group3.id), GroupSummary.find(@deleted_group.id)
      end
    end
  end

  describe '#show' do
    before :each do
      @group = create :group
      @student1 = create :student, group: @group
      @student2 = create :student, group: @group
      @deleted_student = create :student, group: @group, deleted_at: Time.zone.now
    end

    context 'regular visit' do
      before :each do
        get :show, params: { id: @group.id }
      end

      it { should respond_with 200 }

      it { should render_template :show }

      it 'exposes current group' do
        expect(assigns(:group)).to eq @group
      end

      it 'exposes non-deleted students in a group' do
        expect(assigns(:student_table_component).students.map(&:id)).to include @student1.id, @student2.id
        expect(assigns(:student_table_component).students.map(&:id)).not_to include @deleted_student.id
      end
    end

    context 'search' do
      before :each do
        get :show, params: { id: @group.id, search: @student1.first_name }
      end

      it { should respond_with 200 }

      it 'responds with a listed of searched students' do
        expect(assigns(:student_table_component).students.length).to eq 1
        expect(assigns(:student_table_component).students.map(&:id)).to include @student1.id
      end
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
      request.env['HTTP_REFERER'] = 'http://example.com/groups?param=1'

      @students = create_list :student, 2, group: @group

      post :destroy, params: { id: @group.id }
    end

    it { should redirect_to 'http://example.com/groups?param=1' }

    it { should set_flash[:undo_notice] }

    it 'Marks the group as deleted' do
      expect(@group.reload.deleted_at).to be_within(1.second).of Time.zone.now
    end
  end

  describe '#undelete' do
    before :each do
      @group = create :group, deleted_at: Time.zone.now
      request.env['HTTP_REFERER'] = 'http://example.com/groups?param=1'

      post :undelete, params: { id: @group.id }
    end

    it { should redirect_to 'http://example.com/groups?param=1' }

    it { should set_flash[:notice].to "Group \"#{@group.group_name}\" restored." }

    it 'Removes the group\'s deleted timestamp' do
      expect(@group.reload.deleted_at).to be_nil
    end
  end
end
