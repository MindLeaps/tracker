require 'rails_helper'

RSpec.describe OrganizationsController, type: :controller do
  fixtures :organizations
  include_context 'controller_login'

  describe '#index' do
    it 'gets a list of organizations' do
      get :index
      expect(response).to be_success

      expect(assigns(:organizations)).to include organizations(:mindleaps_organization)
      expect(assigns(:organizations)).to include organizations(:good_test_organization)
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
