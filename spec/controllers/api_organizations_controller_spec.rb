# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::OrganizationsController, type: :controller do
  let(:json) { JSON.parse(response.body) }

  before :all do
    @org1 = create :organization, organization_name: 'Org Api Test One'
    @org2 = create :organization, organization_name: 'Org Api Test Two'
    @org3 = create :organization, organization_name: 'Org Api Test Three'
  end

  describe '#index' do
    before :all do
    end
    it 'gets a list of organizations' do
      get :index, format: :json
      expect(response).to be_success
      expect(json.map { |g| g['organization_name'] }).to include 'Org Api Test One',
                                                                 'Org Api Test Two',
                                                                 'Org Api Test Three'
    end
  end
end
