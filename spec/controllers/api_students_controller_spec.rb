require 'rails_helper'

RSpec.describe Api::StudentsController, type: :controller do
  fixtures :students
  fixtures :groups
  let(:json) { JSON.parse(response.body) }
  let(:group_a) { groups(:group_a) }

  describe '#index' do

    it 'gets a list of students' do
      get :index, format: :json

      expect(response).to be_success
      expect(json.map { |s| s['first_name'] }).to include 'Tomislav', 'Innocent', 'Rene'
    end

    it 'gets all students' do
      get :index, format: :json

      expect(json.count).to eq Student.all.count
    end

    it 'get only students belonging to Group A' do
      get :index, params: { group_id: group_a.id }, format: :json

      expect(json.count).to eq 2
      expect(json.map { |s| s['first_name'] }).to include 'Innocent', 'Rene'
    end

    it 'returns empty when group does not exist' do
      get :index, params: { group_id: '123412341234' }, format: :json

      expect(json.count).to eq 0
    end
  end
end
