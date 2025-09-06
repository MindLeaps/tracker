require 'rails_helper'

RSpec.describe OrganizationsController, type: :controller do
  let(:super_admin) { create :super_admin }

  before :each do
    sign_in super_admin
  end

  describe '#index' do
    it 'gets a list of organizations' do
      organization1 = create :organization
      organization2 = create :organization

      get :index
      expect(response).to be_successful

      expect(assigns(:organizations).map(&:organization_name))
        .to include organization1.organization_name, organization2.organization_name
    end
  end

  describe '#new' do
    before :each do
      get :new
    end

    it { should respond_with 200 }
    it { should render_template 'new' }
    it 'assigns the new empty organization' do
      expect(assigns(:organization)).to be_kind_of(Organization)
    end
  end

  describe '#create' do
    let(:existing_org) { create :organization, organization_name: 'Existing Org', mlid: 'EX1' }
    describe 'successful creation' do
      before :each do
        post :create, params: { organization: { organization_name: 'New Test Organization', mlid: 'ABC' } }
      end

      it { should redirect_to organizations_url }
      it { should set_flash[:success_notice] }

      it 'creates a new organization when supplied a valid name and MLID' do
        expect(response).to redirect_to controller: :organizations, action: :index
        organization = Organization.last
        expect(organization.organization_name).to eql 'New Test Organization'
      end
    end
    describe 'failed creation' do
      before :each do
        post :create, params: { organization: { organizations_name: 'Some Name' } }
      end

      it { should respond_with :unprocessable_entity }
      it { should render_template :new }
      it { should set_flash[:failure_notice] }
    end
  end

  describe '#edit' do
    let(:org) { create :organization }
    before :each do
      get :edit, params: { id: org.id }
    end
    it { should respond_with 200 }
    it { should render_template 'edit' }
    it 'assigns the existing organization' do
      expect(assigns(:organization)).to be_kind_of(Organization)
      expect(assigns(:organization).id).to eq(org.id)
    end
  end

  describe '#update' do
    let(:existing_org) { create :organization, organization_name: 'Existing Org', mlid: 'EX1' }
    describe 'successful update' do
      before :each do
        post :update, params: { id: existing_org.id, organization: { organization_name: 'Updated Org', mlid: 'UP1', country_code: 'MK' } }
      end

      it { should redirect_to organizations_url }
      it { should set_flash[:success_notice] }

      it 'updates the name and MLID of an existing org' do
        existing_org.reload
        expect(existing_org.organization_name).to eq 'Updated Org'
        expect(existing_org.mlid).to eq 'UP1'
        expect(existing_org.country).to eq 'North Macedonia'
        expect(existing_org.country_code).to eq 'MK'
      end
    end
    describe 'Failed update' do
      before :each do
        post :update, params: { id: existing_org.id, organization: { mlid: 'INVALID' } }
      end

      it { should respond_with 400 }
      it { should render_template :edit }
      it { should set_flash[:failure_notice] }
    end
  end

  describe '#add_member' do
    before :each do
      @org = create :organization
      @existing_user = create :user

      post :add_member, params: { id: @org.id, user: { email: 'new_user@example.com', role: 'admin' } }
    end

    it { should redirect_to organization_path @org }

    it 'creates a new user with a specified role in the organization' do
      new_user = User.find_by(email: 'new_user@example.com')

      expect(new_user.has_role?(:admin, @org)).to be true
    end

    it 'assigns an existing user, outside of the organization, a role in the organization' do
      post :add_member, params: { id: @org.id, user: { email: @existing_user.email, role: 'admin' } }

      expect(@existing_user.has_role?(:admin, @org)).to be true
    end

    context 'trying to add another role to an existing member of the organization' do
      before :each do
        post :add_member, params: { id: @org.id, user: { email: 'new_user@example.com', role: 'teacher' } }
      end

      it { should respond_with :conflict }
      it { should render_template :show }
      it { should set_flash[:failure_notice] }
    end

    context 'email is missing' do
      before :each do
        post :add_member, params: { id: @org.id, user: {} }
      end

      it { should respond_with :bad_request }
      it { should render_template :show }
      it { should set_flash[:failure_notice] }
    end
  end

  describe '#destroy' do
    before :each do
      @organization = create :organization
      request.env['HTTP_REFERER'] = 'http://example.com/organizations?param=1'

      @chapters = create_list :chapter, 2, organization: @organization
      @groups = create_list :group, 2, chapter: @chapters.first
      @students = create_list :enrolled_student, 2, organization: @groups.first.chapter.organization, groups: [@groups.first]
      @lessons = create_list :lesson, 2, group: @groups.first
      @grades = create_list :grade, 2, lesson: @lessons.first
      @deleted_chapter = create :chapter, organization: @organization, deleted_at: Time.zone.now

      post :destroy, params: { id: @organization.id }
    end

    it { should redirect_to 'http://example.com/organizations?param=1' }

    it { should set_flash[:success_notice] }

    it 'Marks the organization as deleted' do
      expect(@organization.reload.deleted_at).to be_within(1.second).of Time.zone.now
    end

    it 'Marks the organization\'s dependents as deleted' do
      @organization.reload

      @chapters.each { |chapter| expect(chapter.reload.deleted_at).to eq(@organization.deleted_at) }
      @groups.each { |group| expect(group.reload.deleted_at).to eq(@organization.deleted_at) }
      @students.each { |student| expect(student.reload.deleted_at).to eq(@organization.deleted_at) }
      @lessons.each { |lesson| expect(lesson.reload.deleted_at).to eq(@organization.deleted_at) }
      @grades.each { |grade| expect(grade.reload.deleted_at).to eq(@organization.deleted_at) }
    end

    it 'Does not mark previously deleted dependents of the organization as deleted' do
      @organization.reload
      @deleted_chapter.reload

      expect(@deleted_chapter.deleted_at).to_not eq(@organization.deleted_at)
    end
  end

  describe '#undelete' do
    before :each do
      @organization = create :organization, deleted_at: Time.zone.now

      @chapters = create_list :chapter, 2, organization: @organization, deleted_at: @organization.deleted_at
      @groups = create_list :group, 2, chapter: @chapters.first, deleted_at: @organization.deleted_at
      @students = create_list :student, 2, organization: @groups.first.chapter.organization, groups: [@groups.first], deleted_at: @organization.deleted_at
      @lessons = create_list :lesson, 2, group: @groups.first, deleted_at: @organization.deleted_at
      @grades = create_list :grade, 2, lesson: @lessons.first, deleted_at: @organization.deleted_at
      @deleted_chapter = create :chapter, organization: @organization, deleted_at: Time.zone.now

      post :undelete, params: { id: @organization.id }
    end

    it { should set_flash[:success_notice] }

    it 'Removes the organization\'s deleted timestamp' do
      expect(@organization.reload.deleted_at).to be_nil
    end

    it 'Removes the organization\'s dependents deleted timestamps' do
      @chapters.each { |chapter| expect(chapter.reload.deleted_at).to be_nil }
      @groups.each { |group| expect(group.reload.deleted_at).to be_nil }
      @students.each { |student| expect(student.reload.deleted_at).to be_nil }
      @lessons.each { |lesson| expect(lesson.reload.deleted_at).to be_nil }
      @grades.each { |grade| expect(grade.reload.deleted_at).to be_nil }
    end

    it 'Does not remove the previously deleted dependents of the chapter\'s deleted timestamp' do
      @deleted_chapter.reload

      expect(@deleted_chapter.deleted_at).to_not be_nil
    end
  end

  describe '#import' do
    before :each do
      @organization = create :organization

      get :import, format: :turbo_stream, params: { id: @organization.id }
    end

    it { should respond_with 200 }
    it { should render_template :import }
  end

  describe '#import_students' do
    before :each do
      @organization = create :organization
      @valid_file = file_fixture_upload('students_to_import.csv', 'text/csv')

      post :import_students, format: :turbo_stream, params: { id: @organization.id, file: @valid_file }
    end

    it { should respond_with 200 }
    it { should render_template :import_students }

    context 'file is invalid' do
      before :each do
        @invalid_file = file_fixture_upload('test.txt', 'text/plain')

        post :import_students, format: :turbo_stream, params: { id: @organization.id, file: @invalid_file }
      end

      it { should respond_with :unprocessable_entity }
      it { should set_flash.now[:failure_notice] }
    end
  end

  describe '#confirm_import' do
    before :each do
      @organization = create :organization
    end

    context 'students are valid' do
      before :each do
        first_student = { first_name: 'Test', last_name: 'Student', gender: :M, dob: Time.zone.today }.with_indifferent_access
        second_student = { first_name: 'Test', last_name: 'Student', gender: :F, dob: Time.zone.today }.with_indifferent_access
        hash_to_send = [first_student, second_student].each_with_index.to_h { |item, index| [index, item] }

        post :confirm_import, format: :turbo_stream, params: { id: @organization.id, students: hash_to_send }
      end

      it { should redirect_to organization_path(@organization) }
      it { should set_flash[:success_notice] }
      it 'should create and assign students to the organization' do
        @organization.reload
        expect(@organization.students.count).to eq 2
      end
    end


    context 'students are invalid' do
      before :each do
        invalid_student = { first_name: 'Test', last_name: '', gender: :F, dob: Time.zone.today }.with_indifferent_access
        hash_to_send = [invalid_student].each_with_index.to_h { |item, index| [index, item] }

        post :confirm_import, format: :turbo_stream, params: { id: @organization.id, students: hash_to_send }
      end


      it { should respond_with :unprocessable_entity }
      it { should render_template :import_students }
      it { should set_flash.now[:failure_notice] }
      it 'should not create and assign students to organization' do
        @organization.reload
        expect(@organization.students.count).to eq 0
      end
    end
  end
end
