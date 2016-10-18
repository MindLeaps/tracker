# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::StudentsController, type: :controller do
  let(:json) { JSON.parse(response.body) }
  let(:student) { JSON.parse(response.body)['student'] }
  let(:students) { JSON.parse(response.body)['students'] }

  describe '#index' do
    before :each do
      @org1 = create :organization
      @org2 = create :organization

      @group1 = create :group, group_name: 'Api Controller Test Group'
      @group2 = create :group

      create :student, first_name: 'Api', group: @group1, organization: @org1
      create :student, first_name: 'Controller', group: @group1, organization: @org2
      create :student, first_name: 'Spector', group: @group2, organization: @org2

      get :index, format: :json
    end

    it { should respond_with 200 }

    it 'gets a list of students' do
      expect(students.map { |s| s['first_name'] }).to include 'Api', 'Controller', 'Spector'
    end

    it 'responds only with students belonging to a specific group' do
      get :index, params: { group_id: @group1.id }, format: :json

      expect(students.count).to eq 2
      expect(students.map { |s| s['first_name'] }).to include 'Api', 'Controller'
    end

    it 'responds only with students belonging to a specific organization' do
      get :index, params: { organization_id: @org2.id }, format: :json

      expect(students.count).to eq 2
      expect(students.map { |s| s['first_name'] }).to include 'Controller', 'Spector'
    end

    it 'responds with timestamp' do
      expect(Time.zone.parse(json['meta']['timestamp'])).to be_within(1.second).of Time.zone.now
    end

    it 'responds only with students created or updated after a certain time' do
      create :student, created_at: 10.minutes.ago, updated_at: 8.minutes.ago
      create :student, created_at: 1.month.ago, updated_at: 1.day.ago
      create :student, created_at: 4.months.ago, updated_at: 2.minutes.ago

      get :index, format: :json, params: { after_timestamp: 5.minutes.ago }

      expect(json['students'].length).to eq 4
    end
  end

  describe '#show' do
    before :each do
      @org = create :organization
      @group = create :group
      @student = create :student, deleted_at: Time.zone.now, group: @group, organization: @org

      get :show, format: :json, params: { id: @student.id }
    end

    it { should respond_with 200 }

    it 'responds with a specific student' do
      expect(student['first_name']).to eq @student.first_name
      expect(student['last_name']).to eq @student.last_name
      expect(student['id']).to eq @student.id
      expect(student['deleted_at']).to eq @student.deleted_at.iso8601(3)
    end

    it 'responds with timestamp' do
      expect(Time.zone.parse(json['meta']['timestamp'])).to be_within(1.second).of Time.zone.now
    end

    describe 'include' do
      it 'includes group' do
        get :show, format: :json, params: { id: @student.id, include: 'group' }

        expect(student['group']['id']).to eq @group.id
        expect(student['group']['group_name']).to eq @group.group_name
      end

      it 'includes organization' do
        get :show, format: :json, params: { id: @student.id, include: 'organization' }

        expect(student['organization']['id']).to eq @org.id
        expect(student['organization']['organization_name']).to eq @org.organization_name
      end
    end
  end
end
