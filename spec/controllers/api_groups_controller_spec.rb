require 'rails_helper'

RSpec.describe Api::GroupsController, type: :controller do
  let(:json) { JSON.parse(response.body) }

  before :all do
    @chapter = create :chapter, chapter_name: 'Api Group Test Chapter'

    @group1 = create :group, group_name: 'Api Group Test Kigali', chapter: @chapter
    @group2 = create :group, group_name: 'Api Group Test Rugerero'
    @group3 = create :group, group_name: 'Api Group Test Kiregenzi'

    @student1 = create :student, group: @group1
    @student2 = create :student, group: @group1
  end

  describe '#index' do
    before :all do
      
    end
    it 'gets a list of groups' do
      get :index, format: :json
      expect(response).to be_success
      expect(json.map { |g| g['group_name'] }).to include 'Api Group Test Kigali', 'Api Group Test Rugerero', 'Api Group Test Kiregenzi'
    end
  end

  describe '#show' do
    it 'gets a single group' do
      get :show, params: { id: @group1.id }, format: :json
      expect(response).to be_success
      expect(json['group_name']).to eq 'Api Group Test Kigali'
      expect(json['students'].map { |s| s['id'] }).to include @student1.id, @student2.id
      expect(json['chapter_id']).to eq @chapter.id
    end
  end
end
