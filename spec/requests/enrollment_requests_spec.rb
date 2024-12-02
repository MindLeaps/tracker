require 'rails_helper'

RSpec.describe 'Enrollments API', type: :request do
  include_context 'super_admin_request'

  let(:enrollment) { response.parsed_body['enrollment'] }
  let(:enrollments) { response.parsed_body['enrollments'] }

  describe 'GET /enrollment/:id' do
    before :each do
      @enrollment = create @enrollment
    end

    it 'responds with a specific enrollment' do
      get_with_token api_enrollment_path(@enrollment), as: :json

      expect(enrollment['id']).to eq @enrollment.id
      expect(enrollment['group_id']).to eq @enrollment.group_id
      expect(enrollment['student_id']).to eq @enrollment.student_id
      expect(enrollment['active_since']).to eq @enrollment.active_since
      expect(enrollment['inactive_since']).to eq @enrollment.inactive_since
    end

    it 'responds with timestamp' do
      get_with_token api_enrollment_path(@enrollment), as: :json

      expect(response_timestamp).to be_within(1.second).of Time.zone.now
    end
  end

  describe 'GET /enrollments' do
    before :each do
      @group1 = create :group
      @group2 = create :group
      @student1 = create :student
      @student2 = create :student

      @enrollment1 = create :enrollment, group: @group1, student: @student1
      @enrollment2 = create :enrollment, group: @group2, student: @student2
    end

    it 'responds with all enrollments' do
      get_with_token api_enrollments_path, as: :json

      expect(enrollments.length).to eq 2
      expect(enrollments.pluck('id')).to include @enrollment1.id, @enrollment2.id
    end

    it 'responds only with enrollments regarding a specific group' do
      get_with_token api_enrollments_path, params: { group_id: @group1.id }, as: :json

      expect(enrollments.length).to eq 1
      expect(enrollments.pluck('group_id')).to eq @group1.id
    end

    it 'responds only with enrollments regarding a specific student' do
      get_with_token students_path, params: { student_id: @student2.id }, as: :json

      expect(enrollments.length).to eq 1
      expect(enrollments.pluck('student_id')).to eq @student2.id
    end

    it 'responds only with enrollments created or updated after a certain time' do
      create :enrollment, created_at: 10.minutes.ago, updated_at: 8.minutes.ago
      create :enrollment, created_at: 1.month.ago, updated_at: 1.day.ago
      create :enrollment, created_at: 4.months.ago, updated_at: 2.minutes.ago

      get_with_token api_enrollments_path, params: { after_timestamp: 5.minutes.ago }, as: :json

      expect(enrollments.length).to eq 3
    end
  end
end
