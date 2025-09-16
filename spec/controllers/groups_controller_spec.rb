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
                                         mlid: 'g0',
                                         chapter_id: kigali_chapter.id } }
      end

      it 'creates a new group' do
        group = Group.last
        expect(group.group_name).to eql 'New Test Group'
        expect(group.mlid).to eql 'G0'
        expect(group.chapter.chapter_name).to eql 'Newly Created Test Chapter'
      end
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
      @student1 = create :enrolled_student, organization: @group.chapter.organization, groups: [@group]
      @student2 = create :enrolled_student, organization: @group.chapter.organization, groups: [@group]
      @deleted_student = create :enrolled_student, organization: @group.chapter.organization, groups: [@group], deleted_at: Time.zone.now
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
    end

    context 'search' do
      before :each do
        get :show, params: { id: @group.id, search: @student1.first_name }
      end

      it { should respond_with 200 }
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

      it { should set_flash[:success_notice] }

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

      @students = create_list :enrolled_student, 2, organization: @group.chapter.organization, groups: [@group]
      @lessons = create_list :lesson, 2, group: @group
      @grades = create_list :grade, 2, lesson: @lessons.first
      @deleted_student = create :enrolled_student, organization: @group.chapter.organization, groups: [@group], deleted_at: Time.zone.now

      post :destroy, params: { id: @group.id }
    end

    it { should redirect_to 'http://example.com/groups?param=1' }

    it { should set_flash[:success_notice] }

    it 'Marks the group as deleted' do
      expect(@group.reload.deleted_at).to be_within(1.second).of Time.zone.now
    end

    it 'Marks the group\'s dependents as deleted' do
      @group.reload

      @lessons.each { |lesson| expect(lesson.reload.deleted_at).to eq(@group.deleted_at) }
      @grades.each { |grade| expect(grade.reload.deleted_at).to eq(@group.deleted_at) }
    end

    it 'Does not mark previously deleted dependents of the group as deleted' do
      @group.reload
      @deleted_student.reload

      expect(@deleted_student.deleted_at).to_not eq(@group.deleted_at)
    end
  end

  describe '#undelete' do
    before :each do
      @group = create :group, deleted_at: Time.zone.now
      @students = create_list :enrolled_student, 2, organization: @group.chapter.organization, groups: [@group], deleted_at: @group.deleted_at
      @lessons = create_list :lesson, 2, group: @group, deleted_at: @group.deleted_at
      @grades = create_list :grade, 2, lesson: @lessons.first, deleted_at: @group.deleted_at
      @deleted_student = create :enrolled_student, organization: @group.chapter.organization, groups: [@group], deleted_at: Time.zone.now

      post :undelete, params: { id: @group.id }
    end

    it { should set_flash[:success_notice] }

    it 'Removes the group\'s deleted timestamp' do
      expect(@group.reload.deleted_at).to be_nil
    end

    it 'Removes the group\'s dependents deleted timestamps' do
      @lessons.each { |lesson| expect(lesson.reload.deleted_at).to be_nil }
      @grades.each { |grade| expect(grade.reload.deleted_at).to be_nil }
    end

    it 'Does not remove the previously deleted dependents of the group\'s deleted timestamp' do
      @deleted_student.reload

      expect(@deleted_student.deleted_at).to_not be_nil
    end
  end

  describe 'enrollments' do
    before :each do
      @group = create :group
      @unenrolled_students = create_list :student, 2, organization: @group.chapter.organization
    end

    describe '#enroll_students' do
      before :each do
        get :enroll_students, format: :turbo_stream,  params: { id: @group.id }
      end

      it { should respond_with 200 }
      it { should render_template :enroll_students }
    end

    describe '#confirm_enrollments' do
      before :each do
        first_student = { id: @unenrolled_students[0].id, to_enroll: true, enrollment_start_date: 5.days.ago.to_date.to_s }
        second_student = { id: @unenrolled_students[1].id, enrollment_start_date: 5.days.ago.to_date.to_s }
        post :confirm_enrollments, params: { id: @group.id, students: [first_student, second_student] }
      end

      it { should redirect_to group_path(@group) }
      it 'should enroll checked students' do
        @group.reload
        @unenrolled_students.each(&:reload)
        student = @unenrolled_students[0]

        expect(@group.students.count).to eq 1
        expect(student.enrollments.count).to eq 1
        expect(student.enrollments.first.active_since).to eq 5.days.ago.to_date
      end
    end
  end
end
