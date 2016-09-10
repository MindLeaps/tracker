require 'rails_helper'

RSpec.describe Api::StudentsController, type: :controller do
  let(:json) { JSON.parse(response.body) }

  describe '#index' do
    before :all do
      @test_group = create :group, group_name: 'Api Controller Test Group'
      create :student, first_name: 'Api', group: @test_group
      create :student, first_name: 'Controller', group: @test_group
      create :student, first_name: 'Spector', group: @test_group
      create :student, first_name: 'Another'
      create :student, first_name: 'Someone'
    end

    it 'gets a list of students' do
      get :index, format: :json

      expect(response).to be_success
      expect(json.map { |s| s['first_name'] }).to include 'Api', 'Controller', 'Spector', 'Another', 'Someone'
    end

    it 'get only students belonging to Api Controller Test Group' do
      get :index, params: { group_id: @test_group.id }, format: :json

      expect(json.count).to eq 3
      expect(json.map { |s| s['first_name'] }).to include 'Api', 'Controller', 'Spector'
    end
  end
end
