require 'rails_helper'

RSpec.describe OrganizationsController, type: :controller do
  let (:super_admin) { create :super_admin }

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
    it 'creates a new organization when supplied a valid name' do
      post :create, params: { organization: { organization_name: 'New Test Organization' } }

      expect(response).to redirect_to controller: :organizations, action: :index
      organization = Organization.last
      expect(organization.organization_name).to eql 'New Test Organization'
    end
  end
end
