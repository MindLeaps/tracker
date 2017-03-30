# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Assignment API', type: :request do
  include_context 'super_admin_request'

  let(:assignment) { json['assignment'] }
  let(:assignments) { json['assignments'] }
  let(:skill) { json['assignment']['skill'] }
  let(:subject) { json['assignment']['subject'] }

  describe 'GET /assignments/:id' do
    before :each do
      @assignment = create :assignment
    end

    it 'responds with a specific assignment' do
      get_with_token api_assignment_path(@assignment), as: :json

      expect(assignment['id']).to eq @assignment.id
      expect(assignment['subject_id']).to eq @assignment.subject_id
      expect(assignment['skill_id']).to eq @assignment.skill_id
    end

    it 'responds with timestamp' do
      get_with_token api_assignment_path(@assignment), as: :json

      expect(response_timestamp).to be_within(1.second).of Time.zone.now
    end

    it 'responds with a specific assignment including skill' do
      get_with_token api_assignment_path(@assignment), params: { include: 'skill' }, as: :json

      expect(skill['id']).to eq @assignment.skill.id
      expect(skill['skill_name']).to eq @assignment.skill.skill_name
    end

    it 'responds with a specific assignment including subject' do
      get_with_token api_assignment_path(@assignment), params: { include: 'subject' }, as: :json

      expect(subject['id']).to eq @assignment.subject.id
      expect(subject['subject_name']).to eq @assignment.subject.subject_name
    end
  end

  describe 'GET /assignments' do
    before :each do
      @assignment1, @assignment2 = create_list :assignment, 2
      @assignment3 = create :assignment, deleted_at: Time.zone.now
    end

    it 'responds with a list of assignments' do
      get_with_token api_assignments_path, as: :json

      expect(assignments.map { |a| a['id'] }).to include @assignment1.id, @assignment2.id, @assignment3.id
      expect(assignments.map { |a| a['subject_id'] }).to include @assignment1.subject_id, @assignment2.subject_id, @assignment3.subject_id
      expect(assignments.map { |a| a['skill_id'] }).to include @assignment1.skill_id, @assignment2.skill_id, @assignment3.skill_id
    end

    it 'responds with timestamp' do
      get_with_token api_assignments_path, as: :json
      expect(response_timestamp).to be_within(1.second).of Time.zone.now
    end

    it 'responds only with assignments created or updated after a certain time' do
      create :assignment, created_at: 3.months.ago, updated_at: 3.months.ago
      create :assignment, created_at: 2.months.ago, updated_at: 2.months.ago
      create :assignment, created_at: 4.months.ago, updated_at: 1.hour.ago

      get_with_token api_assignments_path, params: { after_timestamp: 1.day.ago }, as: :json

      expect(assignments.length).to eq 4
    end

    it 'responds only with non-deleted assignments' do
      get_with_token api_assignments_path, params: { exclude_deleted: true }, as: :json

      expect(assignments.length).to eq 2
      expect(assignments.map { |s| s['id'] }).to include @assignment1.id, @assignment2.id
    end
  end
end
