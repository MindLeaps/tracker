# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Skill API', type: :request do
  include_context 'super_admin_request'

  let(:skill) { json['skill'] }
  let(:skills) { json['skills'] }
  let(:organization) { json['skill']['organization'] }
  let(:subjects) { json['skill']['subjects'] }
  let(:grade_descriptors) { json['skill']['grade_descriptors'] }

  describe 'GET /skills/:id' do
    before :each do
      @org = create :organization
      @subject = create :subject, organization: @org
      @skill = create :skill_in_subject, organization: @org, subject: @subject
      @grade_descriptor1, @grade_descriptor2 = create_list :grade_descriptor, 2, skill: @skill
    end

    it 'responds with a specific skill' do
      get_with_token skill_path(@skill), as: :json

      expect(skill['id']).to eq @skill.id
      expect(skill['skill_name']).to eq @skill.skill_name
      expect(skill['organization_id']).to eq @skill.organization_id
    end

    it 'responds with timestamp' do
      get_with_token skill_path(@skill), as: :json

      expect(response_timestamp).to be_within(1.second).of Time.zone.now
    end

    it 'responds with a specific skill including organization' do
      get_with_token skill_path(@skill), params: { include: 'organization' }, as: :json

      expect(organization['id']).to eq @org.id
      expect(organization['organization_name']).to eq @org.organization_name
    end

    it 'responds with a specific skill including subjects' do
      get_with_token skill_path(@skill), params: { include: 'subjects' }, as: :json

      expect(subjects.map { |s| s['id'] }).to include @subject.id
      expect(subjects.map { |s| s['subject_name'] }).to include @subject.subject_name
    end

    it 'responds with a specific skill including grade descriptors' do
      get_with_token skill_path(@skill), params: { include: 'grade_descriptors' }, as: :json

      expect(grade_descriptors.map { |l| l['id'] }).to include @grade_descriptor1.id, @grade_descriptor2.id
      expect(grade_descriptors.map { |l| l['mark'] }).to include @grade_descriptor1.mark, @grade_descriptor2.mark
      expect(grade_descriptors.map { |l| l['grade_description'] }).to include @grade_descriptor1.grade_description, @grade_descriptor2.grade_description
    end
  end

  describe 'GET /skills' do
    before :each do
      @org = create :organization
      @org2 = create :organization
      @subject = create :subject, organization: @org
      @skill1, @skill2 = create_list :skill_in_subject, 2, subject: @subject, organization: @org, deleted_at: Time.zone.now
      @skill3 = create :skill, organization: @org2
    end

    it 'responds with a list of skills' do
      get_with_token skills_path, as: :json

      expect(skills.map { |s| s['id'] }).to include @skill1.id, @skill2.id, @skill3.id
      expect(skills.map { |s| s['skill_name'] }).to include @skill1.skill_name, @skill2.skill_name, @skill3.skill_name
    end

    it 'responds with timestamp' do
      get_with_token skills_path, as: :json
      expect(response_timestamp).to be_within(1.second).of Time.zone.now
    end

    it 'responds only with skills created or updated after a certain time' do
      create :skill, created_at: 3.months.ago, updated_at: 3.months.ago
      create :skill, created_at: 2.months.ago, updated_at: 2.months.ago
      create :skill, created_at: 4.months.ago, updated_at: 1.hour.ago

      get_with_token skills_path, params: { after_timestamp: 1.day.ago }, as: :json

      expect(skills.length).to eq 4
    end

    it 'responds only with skills belonging to a specific organization' do
      get_with_token skills_path, params: { organization_id: @org.id }, as: :json

      expect(skills.length).to eq 2
      expect(skills.map { |s| s['id'] }).to include @skill1.id, @skill2.id
    end

    it 'responds only with skills that are part of a specific subject' do
      get_with_token skills_path, params: { subject_id: @subject.id }, as: :json

      expect(skills.length).to eq 2
      expect(skills.map { |s| s['id'] }).to include @skill1.id, @skill2.id
    end

    it 'responds only with non-deleted skills' do
      get_with_token skills_path, params: { exclude_deleted: true }, as: :json

      expect(skills.length).to eq 1
      expect(skills.map { |s| s['id'] }).to include @skill3.id
    end
  end
end
