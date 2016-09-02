require 'rails_helper'

RSpec.describe Api::ChaptersController, type: :controller do
  fixtures :groups
  fixtures :students
  fixtures :chapters
  let(:json) { JSON.parse(response.body) }
  let(:kigali_chapter) { chapters(:kigali_chapter) }
  let(:group_ids) { [groups(:group_a), groups(:group_b)].map(&:id) }

  describe '#index' do
    it 'gets a list of chapters' do
      get :index, format: :json
      expect(response).to be_success
      expect(json.map { |g| g['chapter_name'] }).to include 'Kigali'
      expect(json[0]['groups'].map { |g| g['group_name'] }).to include groups(:group_a).group_name
    end
  end

  describe '#show' do
    it 'gets a single chapter' do
      get :show, params: { id: kigali_chapter.id }, format: :json
      expect(response).to be_success
      expect(json['chapter_name']).to eq kigali_chapter.chapter_name
      expect(json['groups'].map { |g| g['id'] }).to include(*group_ids)
    end
  end
end
