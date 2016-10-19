# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::AssignmentsController, type: :controller do
  let(:json) { JSON.parse(response.body) }
  let(:assignments) { JSON.parse(response.body)['assignments'] }
  let(:assignment) { JSON.parse(response.body)['assignment'] }

  describe '#index' do
    before :each do
      @subject = create :subject

      @skill1 = create :skill_in_subject, subject: @subject
      @skill2 = create :skill_in_subject, subject: @subject
      @skill3 = create :skill_in_subject, subject: @subject

      @a1 = @skill1.assignments[0]
      @a2 = @skill2.assignments[0]
      @a3 = @skill3.assignments[0]

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
  end

  describe '#show' do
    before :each do
      @subject = create :subject
      @skill = create :skill_in_subject, subject: @subject
      @a = @skill.assignments[0]

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
  end
end
