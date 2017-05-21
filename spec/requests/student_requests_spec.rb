# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Student API', type: :request do
  include_context 'super_admin_request'

  let(:student) { JSON.parse(response.body)['student'] }
  let(:students) { JSON.parse(response.body)['students'] }

  describe 'GET /students/:id' do
    before :each do
      @org = create :organization
      @group = create :group
      @student = create :student, group: @group, organization: @org, deleted_at: Time.zone.now
    end

    it 'responds with a specific student' do
      get_with_token student_path(@student), as: :json

      expect(student['first_name']).to eq @student.first_name
      expect(student['last_name']).to eq @student.last_name
      expect(student['id']).to eq @student.id
      expect(student['deleted_at']).to eq @student.deleted_at.iso8601(3)
    end

    it 'responds with timestamp' do
      get_with_token student_path(@student), as: :json

      expect(response_timestamp).to be_within(1.second).of Time.zone.now
    end

    it 'responds with a student including their group and organization' do
      get_with_token student_path(@student), params: { include: 'group,organization' }, as: :json

      expect(student['group']['group_name']).to eq @group.group_name
      expect(student['organization']['organization_name']).to eq @org.organization_name
    end
  end

  describe 'GET /students' do
    before :each do
      @org = create :organization
      @org2 = create :organization

      @group1 = create :group
      @group2 = create :group

      @student1 = create :student, first_name: 'Api', group: @group1, organization: @org, deleted_at: Time.zone.now
      @student2 = create :student, first_name: 'Controller', group: @group1, organization: @org
      @student3 = create :student, first_name: 'Spector', group: @group2, organization: @org2
    end

    it 'responds with all students' do
      get_with_token students_path, as: :json

      expect(students.length).to eq 3
      expect(students.map { |s| s['first_name'] }).to include 'Api', 'Controller', 'Spector'
    end

    it 'responds only with students belonging to a specific group' do
      get_with_token students_path, params: { group_id: @group1.id }, as: :json

      expect(students.length).to eq 2
      expect(students.map { |s| s['first_name'] }).to include 'Api', 'Controller'
    end

    it 'responds with students including their group and organization' do
      get_with_token students_path, params: { include: 'group,organization' }, as: :json

      expect(students.length).to eq 3
      expect(students.map { |s| s['group']['group_name'] }).to include @group1.group_name, @group2.group_name
      expect(students.map { |s| s['organization']['organization_name'] }).to include @org.organization_name, @org2.organization_name
    end

    it 'responds only with students belonging to a specific organization' do
      get_with_token students_path, params: { organization_id: @org2.id }, as: :json

      expect(students.count).to eq 1
      expect(students.map { |s| s['first_name'] }).to include 'Spector'
    end

    it 'responds only with students created or updated after a certain time' do
      create :student, created_at: 10.minutes.ago, updated_at: 8.minutes.ago
      create :student, created_at: 1.month.ago, updated_at: 1.day.ago
      create :student, created_at: 4.months.ago, updated_at: 2.minutes.ago

      get_with_token students_path, params: { after_timestamp: 5.minutes.ago }, as: :json

      expect(json['students'].length).to eq 4
    end

    it 'responds only with non-deleted students' do
      get_with_token students_path, params: { exclude_deleted: true }, as: :json

      expect(students.length).to eq 2
      expect(students.map { |s| s['id'] }).to include @student2.id, @student3.id
    end
  end
end
