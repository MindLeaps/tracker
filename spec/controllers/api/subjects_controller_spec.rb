# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::SubjectsController, type: :controller do
  let(:admin) { create :admin }

  before :each do
    sign_in admin
  end

  describe '#index' do
    before :each do
      @org1 = create :organization
      @org2 = create :organization

      @subject1 = create :subject, organization: @org1
      @subject2 = create :subject, organization: @org1
      @subject3 = create :subject, organization: @org2

      get :index, format: :json
    end

    it { should respond_with 200 }

    it 'responds with all subjects' do
      expect(json['subjects'].map { |s| s['id'] }).to include @subject1.id, @subject2.id, @subject3.id
      expect(json['subjects'].map { |s| s['subject_name'] }).to include @subject1.subject_name, @subject2.subject_name, @subject3.subject_name
    end

    it 'responds with timestamp' do
      expect(response_timestamp).to be_within(1.second).of Time.zone.now
    end

    it 'lists only subjects created or updated after a certain time' do
      create :subject, created_at: 3.months.ago, updated_at: 3.months.ago
      create :subject, created_at: 2.months.ago, updated_at: 2.months.ago
      create :subject, created_at: 4.months.ago, updated_at: 3.months.ago

      get :index, format: :json, params: { after_timestamp: 1.day.ago }

      expect(json['subjects'].length).to eq 3
    end

    it 'lists only subjects belonging to a specific organization' do
      get :index, format: :json, params: { organization_id: @org1 }

      expect(json['subjects'].length).to eq 2
    end
  end

  describe '#show' do
    before :each do
      @organization = create :organization
      @subject = create :subject, organization: @organization
      @skill1 = create :skill_in_subject, subject: @subject
      @skill2 = create :skill_in_subject, subject: @subject
      @lesson1 = create :lesson, subject: @subject
      @lesson2 = create :lesson, subject: @subject

      get :show, format: :json, params: { id: @subject.id }
    end

    it { should respond_with 200 }

    it 'responds with subject' do
      expect(json['subject']['id']).to eq @subject.id
      expect(json['subject']['subject_name']).to eq @subject.subject_name
    end

    it 'responds with timestamp' do
      expect(response_timestamp).to be_within(1.second).of Time.zone.now
    end

    describe 'include' do
      it 'includes skills' do
        get :show, format: :json, params: { id: @subject.id, include: 'skills' }

        skills = json['subject']['skills']
        expect(skills.map { |s| s['id'] }).to include @skill1.id, @skill2.id
      end

      it 'includes lessons' do
        get :show, format: :json, params: { id: @subject.id, include: 'lessons' }

        lessons = json['subject']['lessons']
        expect(lessons.map { |s| s['id'] }).to include @lesson1.id, @lesson2.id
      end

      it 'includes organization' do
        get :show, format: :json, params: { id: @subject.id, include: 'organization' }

        expect(json['subject']['organization']['id']).to eq @organization.id
      end
    end
  end
end
