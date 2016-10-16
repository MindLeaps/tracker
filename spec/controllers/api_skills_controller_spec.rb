# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::SkillsController, type: :controller do
  let(:json) { JSON.parse(response.body) }

  describe '#index' do
    before :each do
      @org1 = create :organization
      @org2 = create :organization

      @subject = create :subject

      @skill1 = create :skill_in_subject, organization: @org1, subject: @subject
      @skill2 = create :skill, organization: @org1
      @skill3 = create :skill, organization: @org2

      get :index, format: :json
    end

    it { should respond_with 200 }

    it 'responds with a list of skills' do
      expect(json['skills'].length).to eq 3
      expect(json['skills'].map { |s| s['id'] }).to include @skill1.id, @skill2.id, @skill3.id
      expect(json['skills'].map { |s| s['skill_name'] }).to include @skill1.skill_name, @skill2.skill_name, @skill3.skill_name
      expect(json['skills'].map { |s| s['skill_description'] }).to include @skill1.skill_description, @skill2.skill_description, @skill3.skill_description
      expect(json['skills'].map { |s| s['organization_id'] }).to include @skill1.organization_id, @skill2.organization_id, @skill3.organization_id
    end

    it 'responds with timestamp' do
      expect(Time.zone.parse(json['meta']['timestamp'])).to be_within(1.second).of Time.zone.now
    end

    it 'responds only with skills created or updated after a certain time' do
      create :skill, created_at: 3.months.ago, updated_at: 3.months.ago
      create :skill, created_at: 2.months.ago, updated_at: 2.months.ago
      create :skill, created_at: 4.months.ago, updated_at: 3.months.ago

      get :index, format: :json, params: { after_timestamp: 1.day.ago }

      expect(json['skills'].length).to eq 3
    end

    it 'responds only with skills belonging to a specific organization' do
      get :index, format: :json, params: { organization_id: @org1.id }

      expect(json['skills'].length).to eq 2
      expect(json['skills'].map { |s| s['id'] }).to include @skill1.id, @skill2.id
    end

    it 'reponds only with skills that are included in a specific subject' do
      get :index, format: :json, params: { subject_id: @subject.id }

      expect(json['skills'].length).to eq 1
      expect(json['skills'].map { |s| s['id'] }).to include @skill1.id
    end
  end

  describe '#show' do
    before :each do
      @skill = create :skill

      get :show, format: :json, params: { id: @skill.id }
    end

    it { should respond_with 200 }

    it 'responds with a skill' do
      expect(json['skill']['id']).to eq @skill.id
      expect(json['skill']['skill_name']).to eq @skill.skill_name
      expect(json['skill']['skill_description']).to eq @skill.skill_description
      expect(json['skill']['organization_id']).to eq @skill.organization_id
    end

    it 'responds with timestamp' do
      expect(Time.zone.parse(json['meta']['timestamp'])).to be_within(1.second).of Time.zone.now
    end
  end
end
