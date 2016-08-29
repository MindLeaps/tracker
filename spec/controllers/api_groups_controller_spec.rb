require 'rails_helper'

RSpec.describe Api::GroupsController, type: :controller do
  fixtures :groups
  fixtures :students
  let(:json) { JSON.parse(response.body) }
  let(:student_ids) { [students(:innocent), students(:rene)].map(&:id) }

  describe '#index' do
    it 'gets a list of groups' do
      get :index, format: :json
      expect(response).to be_success
      expect(json.map { |g| g['group_name'] }).to include 'Group A'
    end
  end

  describe '#show' do
    it 'gets a single group' do
      get :show, params: { id: groups(:group_a).id }, format: :json
      expect(response).to be_success
      expect(json['group_name']).to eq 'Group A'
      expect(json['students'].map { |s| s['id'] }).to include(*student_ids)
    end
  end
end
