require 'rails_helper'

RSpec.describe 'DeletedLesson API', type: :request do
  include_context 'super_admin_request'

  let(:deleted_lessons) { json['deleted_lessons'] }

  describe 'GET /deleted_lessons' do
    before :each do
      @group = create :group
      @deleted_lesson_one = create :deleted_lesson, group: @group, created_at: 2.days.ago, updated_at: 2.days.ago
      @deleted_lesson_two = create :deleted_lesson, group: @group, created_at: 1.day.ago, updated_at: 1.day.ago
    end

    it 'responds with a list of deleted lessons' do
      get_v2_with_token api_deleted_lessons_path, as: :json

      expect(response).to be_successful
      expect(deleted_lessons.length).to eq 2
      expect(deleted_lessons.pluck('id')).to include @deleted_lesson_one.lesson_id, @deleted_lesson_two.lesson_id
      expect(deleted_lessons.pluck('lesson_id')).to include @deleted_lesson_one.lesson_id, @deleted_lesson_two.lesson_id
    end

    it 'responds only with deleted lessons created or updated after a certain time' do
      get_v2_with_token api_deleted_lessons_path, params: { after_timestamp: 36.hours.ago.iso8601 }, as: :json

      expect(deleted_lessons.length).to eq 1
      expect(deleted_lessons.first['lesson_id']).to eq @deleted_lesson_two.lesson_id
    end

    it 'responds with timestamp' do
      get_v2_with_token api_deleted_lessons_path, as: :json

      expect(response_timestamp).to be_within(1.second).of Time.zone.now
    end
  end
end
