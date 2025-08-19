require 'rails_helper'

RSpec.describe 'Student API', type: :request do
  include_context 'super_admin_request'

  let(:student) { response.parsed_body['student'] }
  let(:students) { response.parsed_body['students'] }

  describe 'GET /students/:id' do
    before :each do
      @org = create :organization
      @chapter = create :chapter, organization: @org
      @first_group = create :group, chapter: @chapter
      @current_group = create :group, chapter: @chapter
      @student = create :enrolled_student, organization: @org, groups: [@first_group], deleted_at: Time.zone.now
      create :enrollment, student: @student, group: @current_group, active_since: 1.day.from_now
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

    it 'responds with a student including their enrollments' do
      get_with_token student_path(@student), params: { include: 'enrollments' }, as: :json

      expect(student['enrollments'].count).to eq 2
      expect(student['enrollments'].pluck('group_id')).to include @first_group.id, @current_group.id
    end
  end

  describe 'GET /students' do
    register_encoder :csv, param_encoder: ->(params) { params.to_s }

    before :each do
      @org1 = create :organization
      @org2 = create :organization
      @group1 = create :group, chapter: create(:chapter, organization: @org1)
      @group2 = create :group, chapter: create(:chapter, organization: @org2)

      @student1 = create :enrolled_student, first_name: 'Api', organization: @org1, groups: [@group1], deleted_at: Time.zone.now
      @student2 = create :enrolled_student, first_name: 'Controller', organization: @org1, groups: [@group1]
      @student3 = create :enrolled_student, first_name: 'Spector', organization: @org2, groups: [@group2]
    end

    it 'responds with all students' do
      get_with_token students_path, as: :json

      expect(students.length).to eq 3
      expect(students.pluck('first_name')).to include 'Api', 'Controller', 'Spector'
    end

    it 'responds only with students belonging to a specific organization' do
      get_with_token students_path, params: { organization_id: @org1.id }, as: :json

      expect(students.length).to eq 2
      expect(students.pluck('first_name')).to include 'Api', 'Controller'
    end

    it 'responds only with students enrolled to a specific group' do
      get_with_token students_path, params: { group_id: @group2.id }, as: :json

      expect(students.length).to eq 1
      expect(students.pluck('first_name')).to include 'Spector'
    end

    it 'responds with students including their enrollments and organization' do
      get_with_token students_path, params: { include: 'enrollments' }, as: :json

      expect(students.length).to eq 3
      expect(students.flat_map { |s| s['enrollments'].map { |e| e['group_id'] } }).to include @group1.id, @group2.id
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
