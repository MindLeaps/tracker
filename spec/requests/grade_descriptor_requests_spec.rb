require 'rails_helper'

RSpec.describe 'Grade Descriptor API', type: :request do
  include_context 'super_admin_request'

  let(:grade_descriptor) { json['grade_descriptor'] }
  let(:grade_descriptors) { json['grade_descriptors'] }
  let(:skill) { json['grade_descriptor']['skill'] }
  let(:subject) { json['grade_descriptor']['subject'] }

  describe 'GET /grade_descriptors/:id' do
    before :each do
      @gd = create :grade_descriptor
    end

    it 'responds with a specific grade descriptor' do
      get_with_token api_grade_descriptor_path(@gd), as: :json

      expect(grade_descriptor['id']).to eq @gd.id
      expect(grade_descriptor['mark']).to eq @gd.mark
      expect(grade_descriptor['grade_description']).to eq @gd.grade_description
    end

    it 'responds with timestamp' do
      get_with_token api_grade_descriptor_path(@gd), as: :json

      expect(response_timestamp).to be_within(1.second).of Time.zone.now
    end

    it 'responds with a specific grade descriptor including skill' do
      get_with_token api_grade_descriptor_path(@gd), params: { include: 'skill' }, as: :json

      expect(skill['id']).to eq @gd.skill.id
      expect(skill['skill_name']).to eq @gd.skill.skill_name
    end
  end

  describe 'GET /grade_descriptors' do
    before :each do
      @skill1, @skill2 = create_list :skill, 2
      @gd1, @gd2 = create_list :grade_descriptor, 2, skill: @skill1
      @gd3 = create :grade_descriptor, deleted_at: Time.zone.now, skill: @skill2
    end

    it 'responds with a list of grade descriptors' do
      get_with_token api_grade_descriptors_path, as: :json

      expect(grade_descriptors.pluck('id')).to include @gd1.id, @gd2.id, @gd3.id
      expect(grade_descriptors.pluck('mark')).to include @gd1.mark, @gd2.mark, @gd3.mark
      expect(grade_descriptors.pluck('grade_description')).to include @gd1.grade_description, @gd2.grade_description, @gd3.grade_description
    end

    it 'responds with timestamp' do
      get_with_token api_grade_descriptors_path, as: :json
      expect(response_timestamp).to be_within(1.second).of Time.zone.now
    end

    it 'responds only with grade descriptors created or updated after a certain time' do
      create :grade_descriptor, created_at: 3.months.ago, updated_at: 3.months.ago
      create :grade_descriptor, created_at: 2.months.ago, updated_at: 2.months.ago
      create :grade_descriptor, created_at: 4.months.ago, updated_at: 1.hour.ago

      get_with_token api_grade_descriptors_path, params: { after_timestamp: 1.day.ago }, as: :json

      expect(grade_descriptors.length).to eq 4
    end

    it 'responds only with grade descriptors belonging to a specific skill' do
      get_with_token api_grade_descriptors_path, params: { skill_id: @skill2.id }, as: :json

      expect(grade_descriptors.length).to eq 1
      expect(grade_descriptors.pluck('id')).to include @gd3.id
      expect(grade_descriptors.pluck('mark')).to include @gd3.mark
      expect(grade_descriptors.pluck('grade_description')).to include @gd3.grade_description
    end

    it 'responds only with non-deleted grade descriptors' do
      get_with_token api_grade_descriptors_path, params: { exclude_deleted: true }, as: :json

      expect(grade_descriptors.length).to eq 2
      expect(grade_descriptors.pluck('id')).to include @gd1.id, @gd2.id
    end
  end
end
