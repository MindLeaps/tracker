# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Subject API', type: :request do
  include_context 'super_admin_request'

  let(:subject) { json['subject'] }
  let(:subjects) { json['subjects'] }
  let(:organization) { json['subject']['organization'] }
  let(:lessons) { json['subject']['lessons'] }
  let(:skills) { json['subject']['skills'] }

  describe 'GET /subjects/:id' do
    before :each do
      @org = create :organization
      @subject = create :subject, organization: @org
      @lesson1, @lesson2 = create_list :lesson, 2, subject: @subject
      @skill1, @skill2 = create_list :skill_in_subject, 2, subject: @subject
    end

    it 'responds with a specific subject' do
      get_with_token subject_path(@subject), as: :json

      expect(subject['id']).to eq @subject.id
      expect(subject['subject_name']).to eq @subject.subject_name
      expect(subject['organization_id']).to eq @org.id
    end

    it 'responds with timestamp' do
      get_with_token subject_path(@subject), as: :json

      expect(response_timestamp).to be_within(1.second).of Time.zone.now
    end

    it 'responds with a specific subject including organization' do
      get_with_token subject_path(@subject), params: { include: 'organization' }, as: :json

      expect(organization['id']).to eq @org.id
      expect(organization['organization_name']).to eq @org.organization_name
    end

    it 'responds with a specific subject including lessons' do
      get_with_token subject_path(@subject), params: { include: 'lessons' }, as: :json

      expect(lessons.map { |l| l['id'] }).to include @lesson1.id, @lesson2.id
    end

    it 'responds with a specific subject including skills' do
      get_with_token subject_path(@subject), params: { include: 'skills' }, as: :json

      expect(skills.map { |l| l['id'] }).to include @skill1.id, @skill2.id
      expect(skills.map { |l| l['skill_name'] }).to include @skill1.skill_name, @skill2.skill_name
    end
  end

  describe 'GET /subjects' do
    before :each do
      @org = create :organization
      @subject1, @subject2 = create_list :subject, 2, organization: @org
      @subject3 = create :subject
    end

    it 'responds with a list of subjects' do
      get_with_token subjects_path, as: :json

      expect(subjects.map { |s| s['id'] }).to include @subject1.id, @subject2.id, @subject3.id
      expect(subjects.map { |s| s['subject_name'] }).to include @subject1.subject_name, @subject2.subject_name, @subject3.subject_name
    end

    it 'responds with timestamp' do
      get_with_token subjects_path, as: :json
      expect(response_timestamp).to be_within(1.second).of Time.zone.now
    end

    it 'responds only with subjects created or updated after a certain time' do
      create :subject, created_at: 2.months.ago, updated_at: 2.days.ago
      create :subject, created_at: 2.months.ago, updated_at: 5.days.ago
      create :subject, created_at: 5.days.ago, updated_at: 6.hours.ago

      get_with_token subjects_path, params: { after_timestamp: 1.day.ago }, as: :json

      expect(subjects.length).to eq 4
    end

    it 'responds only with subjects belonging to a specific organization' do
      get_with_token subjects_path, params: { organization_id: @org.id }, as: :json

      expect(subjects.length).to eq 2
      expect(subjects.map { |s| s['id'] }).to include @subject1.id, @subject2.id
    end
  end
end
