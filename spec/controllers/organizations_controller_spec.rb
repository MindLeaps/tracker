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

      post :add_member, params: { id: @org.id, member: { email: @existing_user.email, role: 'admin' } }
    end

    it { should redirect_to organization_path @org }

    it 'adds a member with a specified role to the organization' do
      expect(response).to be_success

      expect(@existing_user.has_role?(:admin, org)).to be true
    end
  end
end
