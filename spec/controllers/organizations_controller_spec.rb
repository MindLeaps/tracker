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
      expect(response).to be_success

      expect(assigns(:organizations)).to include organization1
      expect(assigns(:organizations)).to include organization2
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
    it 'creates a new organization when supplied a valid name' do
      post :create, params: { organization: { organization_name: 'New Test Organization' } }

      expect(response).to redirect_to controller: :organizations, action: :index
      organization = Organization.last
      expect(organization.organization_name).to eql 'New Test Organization'
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
