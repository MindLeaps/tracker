# frozen_string_literal: true

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
        post :create, params: { organization: { organizations_name: 'Some Name' }}
      end

      it { should respond_with :bad_request }
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
        post :update, params: { id: existing_org.id, organization: { organization_name: 'Updated Org', mlid: 'UP1' } }
      end

      it { should redirect_to organizations_url }
      it { should set_flash[:success_notice]}

      it 'updates the name and MLID of an existing org' do
        existing_org.reload
        expect(existing_org.organization_name).to eq 'Updated Org'
        expect(existing_org.mlid).to eq 'UP1'
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

      post :add_member, params: { id: @org.id, member: { email: 'new_user@example.com', role: 'admin' } }
    end

    it { should redirect_to organization_path @org }

    it 'creates a new user with a specified role in the organization' do
      new_user = User.find_by(email: 'new_user@example.com')

      expect(new_user.has_role?(:admin, @org)).to be true
    end

    it 'assigns an existing user, outside of the organization, a role in the organization' do
      post :add_member, params: { id: @org.id, member: { email: @existing_user.email, role: 'admin' } }

      expect(@existing_user.has_role?(:admin, @org)).to be true
    end

    context 'trying to add another role to an existing member of the organization' do
      before :each do
        post :add_member, params: { id: @org.id, member: { email: 'new_user@example.com', role: 'teacher' } }
      end

      it { should respond_with :conflict }
      it { should render_template :show }
      it { should set_flash[:alert].to 'User is already a member of the organization' }
    end

    context 'email is missing' do
      before :each do
        post :add_member, params: { id: @org.id, member: {} }
      end

      it { should respond_with :bad_request }
      it { should render_template :show }
      it { should set_flash[:alert].to 'Member Email missing' }
    end
  end
end
