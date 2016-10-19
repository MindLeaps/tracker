# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::AssignmentsController, type: :controller do
  let(:json) { JSON.parse(response.body) }
  let(:assignments) { JSON.parse(response.body)['assignments'] }
  let(:assignment) { JSON.parse(response.body)['assignment'] }

  describe '#index' do
    before :each do
      @a1 = create :assignment
      @a2 = create :assignment
      @a3 = create :assignment, deleted_at: Time.zone.now

      get :index, format: :json
    end

    it { should respond_with 200 }

    it 'responds with all assignments' do
      expect(assignments.map { |a| a['id'] }).to include @a1.id, @a2.id, @a3.id
      expect(assignments.map { |a| a['skill_id'] }).to include @a1.skill_id, @a2.skill_id, @a3.skill_id
      expect(assignments.map { |a| a['subject_id'] }).to include @a1.subject_id, @a2.subject_id, @a3.subject_id
    end

    it 'responds with timestamp' do
      expect(Time.zone.parse(json['meta']['timestamp'])).to be_within(1.second).of Time.zone.now
    end

    it 'responds only with assignments created or updated after a certain time' do
      create :assignment, created_at: 2.months.ago, updated_at: 2.days.ago
      create :assignment, created_at: 2.months.ago, updated_at: 5.days.ago
      create :assignment, created_at: 5.days.ago, updated_at: 6.hours.ago

      get :index, format: :json, params: { after_timestamp: 1.day.ago }

      expect(assignments.length).to eq 4
    end

    it 'excludes deleted assignments from the response' do
      get :index, format: :json, params: { exclude_deleted: true }

      expect(assignments.length).to eq 2
      expect(assignments.map { |o| o['id'] }).to include @a1.id, @a2.id
    end
  end

  describe '#show' do
    before :each do
      @a = create :assignment

      get :show, format: :json, params: { id: @a.id }
    end

    it { should respond_with 200 }

    it 'responds with a specific assignment' do
      expect(assignment['id']).to eq @a.id
      expect(assignment['subject_id']).to eq @a.subject_id
      expect(assignment['skill_id']).to eq @a.skill_id
    end

    it 'responds with timestamp' do
      expect(Time.zone.parse(json['meta']['timestamp'])).to be_within(1.second).of Time.zone.now
    end

    describe 'include' do
      it 'includes the skill' do
        get :show, format: :json, params: { id: @a.id, include: 'skill' }

        expect(assignment['skill']['id']).to eq @a.skill.id
        expect(assignment['skill']['skill_name']).to eq @a.skill.skill_name
      end

      it 'includes the subject' do
        get :show, format: :json, params: { id: @a.id, include: 'subject' }

        expect(assignment['subject']['id']).to eq @a.subject.id
        expect(assignment['subject']['subject_name']).to eq @a.subject.subject_name
      end
    end
  end
end
