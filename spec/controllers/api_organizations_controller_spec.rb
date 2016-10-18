# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::OrganizationsController, type: :controller do
  let(:json) { JSON.parse(response.body) }
  let(:organizations) { JSON.parse(response.body)['organizations'] }
  let(:organization) { JSON.parse(response.body)['organization'] }

  describe '#index' do
    before :each do
      @org1 = create :organization
      @org2 = create :organization
      @org3 = create :organization

      get :index, format: :json
    end

    it { should respond_with 200 }

    it 'gets a list of organizations' do
      expect(response).to be_success
      expect(organizations.map { |g| g['id'] }).to include @org1.id, @org2.id, @org3.id
      expect(organizations.map { |g| g['organization_name'] }).to include @org1.organization_name, @org2.organization_name, @org3.organization_name
    end

    it 'responds with timestamp' do
      expect(Time.zone.parse(json['meta']['timestamp'])).to be_within(1.second).of Time.zone.now
    end
  end

  describe '#show' do
    before :each do
      @org = create :organization, image: 'http://example.com/1.jpg'

      get :show, format: :json, params: { id: @org.id }
    end

    it { should respond_with 200 }

    it 'responds with a requested organization' do
      expect(organization['id']).to eq @org.id
      expect(organization['organization_name']).to eq @org.organization_name
      expect(organization['image']).to eq @org.image
    end

    it 'responds with timestamp' do
      expect(Time.zone.parse(json['meta']['timestamp'])).to be_within(1.second).of Time.zone.now
    end
  end
end
