# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::StudentsController, type: :controller do
  let(:json) { JSON.parse(response.body) }
  let(:student) { JSON.parse(response.body)['student'] }
  let(:students) { JSON.parse(response.body)['students'] }

  describe '#index' do
    before :each do
      @test_group = create :group, group_name: 'Api Controller Test Group'
      create :student, first_name: 'Api', group: @test_group
      create :student, first_name: 'Controller', group: @test_group
      create :student, first_name: 'Spector', group: @test_group
      create :student, first_name: 'Another'
      create :student, first_name: 'Someone'

      get :index, format: :json
    end

    it { should respond_with 200 }

    it 'gets a list of students' do
      expect(students.map { |s| s['first_name'] }).to include 'Api', 'Controller', 'Spector', 'Another', 'Someone'
    end

    it 'get only students belonging to Api Controller Test Group' do
      get :index, params: { group_id: @test_group.id }, format: :json

      expect(students.count).to eq 3
      expect(students.map { |s| s['first_name'] }).to include 'Api', 'Controller', 'Spector'
    end
  end

  describe '#show' do
    before :each do
      @student = create :student

      get :show, format: :json, params: { id: @student.id }
    end

    it { should respond_with 200 }

    it 'responds with a specific student' do
      expect(student['first_name']).to eq @student.first_name
      expect(student['last_name']).to eq @student.last_name
      expect(student['id']).to eq @student.id
    end
  end
end
