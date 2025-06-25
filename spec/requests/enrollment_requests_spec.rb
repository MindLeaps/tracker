require 'rails_helper'

RSpec.describe 'Enrollments API', type: :request do
  include_context 'super_admin_request'

  let(:enrollment) { response.parsed_body['enrollment'] }
  let(:enrollments) { response.parsed_body['enrollments'] }
  # NOTE: Student factory creates an enrollment automatically in the background with a current datetime

  describe 'GET /enrollment/:id' do
    it 'responds with a specific enrollment' do
      created_enrollment = create :enrollment

      get_with_token api_enrollment_path(created_enrollment), as: :json

      expect(enrollment['id']).to eq created_enrollment.id
      expect(enrollment['group_id']).to eq created_enrollment.group_id
      expect(enrollment['student_id']).to eq created_enrollment.student_id
    end

    it 'responds with timestamp' do
      created_enrollment = create :enrollment

      get_with_token api_enrollment_path(created_enrollment), as: :json

      expect(response_timestamp).to be_within(1.second).of Time.zone.now
    end
  end

  describe 'GET /enrollments' do
    it 'responds with all enrollments' do
      enrollments = create_list :enrollment, 2

      get_with_token api_enrollments_path, as: :json

      expect(enrollments.length).to eq 2
      expect(enrollments.pluck('id')).to eq enrollments.pluck(:id)
    end

    it 'responds only with enrollments regarding a specific group' do
      group = create :group
      create :enrollment, group: group

      get_with_token api_enrollments_path, params: { group_id: group.id }, as: :json

      expect(enrollments.length).to eq 1
      expect(enrollments.pluck('group_id')).to include group.id
    end

    it 'responds only with enrollments regarding a specific student' do
      group = create :group
      student = create :enrolled_student, organization: group.chapter.organization, groups: [group]

      get_with_token api_enrollments_path, params: { student_id: student.id }, as: :json

      expect(enrollments.length).to eq 1
      expect(enrollments.pluck('student_id')).to include student.id
    end

    it 'responds only with enrollments created or updated after a certain time' do
      create :enrollment, created_at: 10.minutes.ago, updated_at: 6.minutes.ago
      create :enrollment, created_at: 1.month.ago, updated_at: 1.minute.ago

      get_with_token api_enrollments_path, params: { after_timestamp: 5.minutes.ago }, as: :json

      expect(enrollments.length).to eq 1
    end
  end
end
