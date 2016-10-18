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
      @org3 = create :organization, deleted_at: Time.zone.now

      get :index, format: :json
    end

    it { should respond_with 200 }

    it 'gets a list of organizations' do
      expect(response).to be_success
      expect(organizations.map { |o| o['id'] }).to include @org1.id, @org2.id, @org3.id
      expect(organizations.map { |o| o['organization_name'] }).to include @org1.organization_name, @org2.organization_name, @org3.organization_name
      expect(organizations.map { |o| o['deleted_at'] }).to include @org1.deleted_at, @org2.deleted_at, @org3.deleted_at.iso8601(3)
    end

    it 'responds with timestamp' do
      expect(Time.zone.parse(json['meta']['timestamp'])).to be_within(1.second).of Time.zone.now
    end

    it 'excludes deleted organizations from the response' do
      get :index, format: :json, params: { exclude_deleted: true }

      expect(organizations.length).to eq 2
      expect(organizations.map { |o| o['organization_name'] }).to include @org1.organization_name, @org2.organization_name
    end

    it 'responds only with organizations created or updated after a certain time' do
      create :organization, created_at: 2.months.ago, updated_at: 2.days.ago
      create :organization, created_at: 2.months.ago, updated_at: 5.days.ago
      create :organization, created_at: 5.days.ago, updated_at: 6.hours.ago

      get :index, format: :json, params: { after_timestamp: 1.day.ago }

      expect(organizations.length).to eq 4
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
