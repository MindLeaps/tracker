require 'rails_helper'

RSpec.describe 'Organization API', type: :request do
  include_context 'super_admin_request'

  let(:organization) { response.parsed_body['organization'] }
  let(:organizations) { response.parsed_body['organizations'] }
  let(:chapters) { response.parsed_body['organization']['chapters'] }
  let(:students) { response.parsed_body['organization']['students'] }

  describe 'GET /organizations/:id' do
    before :each do
      @org = create :organization, image: 'http://example.com/1.jpg'

      @chapter1, @chapter2 = create_list :chapter, 2, organization: @org
    end

    it 'responds with a specific organization' do
      get_with_token organization_path(@org), as: :json

      expect(organization['id']).to eq @org.id
      expect(organization['organization_name']).to eq @org.organization_name
      expect(organization['image']).to eq @org.image
    end

    it 'responds with timestamp' do
      get_with_token organization_path(@org), as: :json

      expect(response_timestamp).to be_within(1.second).of Time.zone.now
    end

    it 'responds with a specific organization including chapters' do
      get_with_token organization_path(@org), params: { include: 'chapters' }, as: :json

      expect(chapters.pluck('id')).to include @chapter1.id, @chapter2.id
      expect(chapters.pluck('chapter_name')).to include @chapter1.chapter_name, @chapter2.chapter_name
    end
  end

  describe 'GET /organizations' do
    before :each do
      @org1, @org2 = create_list :organization, 2
      @org3 = create :organization, deleted_at: Time.zone.now
    end

    it 'responds with a list of organizations' do
      get_with_token organizations_path, as: :json

      expect(organizations.pluck('id')).to include @org1.id, @org2.id, @org3.id
      expect(organizations.pluck('organization_name')).to include @org1.organization_name, @org2.organization_name, @org3.organization_name
    end

    it 'responds with timestamp' do
      get_with_token organizations_path, as: :json
      expect(response_timestamp).to be_within(1.second).of Time.zone.now
    end

    it 'responds with a list of non-deleted organizations' do
      get_with_token organizations_path, params: { exclude_deleted: true }, as: :json

      expect(organizations.length).to eq 2
      expect(organizations.pluck('id')).to include @org1.id, @org2.id
    end

    it 'responds only with organizations created or updated after a certain time' do
      create :organization, created_at: 2.months.ago, updated_at: 2.days.ago
      create :organization, created_at: 2.months.ago, updated_at: 5.days.ago
      create :organization, created_at: 5.days.ago, updated_at: 6.hours.ago

      get_with_token organizations_path, params: { after_timestamp: 1.day.ago }, as: :json

      expect(organizations.length).to eq 4
    end
  end
end
