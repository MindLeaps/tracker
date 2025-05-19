require 'rails_helper'

RSpec.describe 'Student API', type: :request do
  include_context 'super_admin_request'

  let(:student) { response.parsed_body['student'] }
  let(:students) { response.parsed_body['students'] }

  describe 'GET /students/:id' do
    before :each do
      @group = create :group
      @current_group = create :group
      @student = create :student, group: @group, deleted_at: Time.zone.now
      create :enrollment, student: @student, group: @current_group, active_since: 1.day.after, inactive_since: nil
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

    it 'responds with a student including their group' do
      get_with_token student_path(@student), params: { include: 'group' }, as: :json

      expect(student['group']['group_name']).to eq @group.group_name
    end

    it "responds with the student's group id as the one where its enrolled" do
      get_with_token student_path(@student), as: :json

      expect(student['group_id']).to_not eq @group.id
      expect(student['group_id']).to eq @current_group.id
    end
  end

  describe 'GET /students' do
    register_encoder :csv, param_encoder: ->(params) { params.to_s }

    before :each do
      @group1 = create :group
      @group2 = create :group

      @student1 = create :student, first_name: 'Api', group: @group1, deleted_at: Time.zone.now
      @student2 = create :student, first_name: 'Controller', group: @group1
      @student3 = create :student, first_name: 'Spector', group: @group2
    end

    it 'responds with all students' do
      get_with_token students_path, as: :json

      expect(students.length).to eq 3
      expect(students.pluck('first_name')).to include 'Api', 'Controller', 'Spector'
    end

    it 'responds only with students belonging to a specific group' do
      get_with_token students_path, params: { group_id: @group1.id }, as: :json

      expect(students.length).to eq 2
      expect(students.pluck('first_name')).to include 'Api', 'Controller'
    end

    it 'responds with students including their group and organization' do
      get_with_token students_path, params: { include: 'group' }, as: :json

      expect(students.length).to eq 3
      expect(students.map { |s| s['group']['group_name'] }).to include @group1.group_name, @group2.group_name
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
      expect(students.pluck('id')).to include @student2.id, @student3.id
    end

    it "responds with a specific group's exported students" do
      get_with_token students_url, params: { group_id: @group1.id, format: :csv }

      expect(response.header['Content-Type']).to include 'text/csv'
      expect(response.body).to include(@student2.first_name, @student2.last_name)
    end
  end
end
