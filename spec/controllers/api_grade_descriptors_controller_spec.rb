# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::GradeDescriptorsController, type: :controller do
  let(:json) { JSON.parse(response.body) }

  describe '#index' do
    before :each do
      @skill1 = create :skill
      @skill2 = create :skill

      @gd1 = create :grade_descriptor, skill: @skill1, deleted_at: Time.zone.now
      @gd2 = create :grade_descriptor, skill: @skill1
      @gd3 = create :grade_descriptor, skill: @skill2

      get :index, format: :json
    end

    it { should respond_with 200 }

    it 'responds with all grade descriptors' do
      expect(json['grade_descriptors'].length).to eq 3
      expect(json['grade_descriptors'].map { |g| g['id'] }).to include @gd1.id, @gd2.id, @gd3.id
      expect(json['grade_descriptors'].map { |g| g['mark'] }).to include @gd1.mark, @gd2.mark, @gd3.mark
      expect(json['grade_descriptors'].map { |g| g['grade_description'] }).to include @gd1.grade_description, @gd2.grade_description, @gd3.grade_description
    end

    it 'responds with timestamp' do
      expect(Time.zone.parse(json['meta']['timestamp'])).to be_within(1.second).of Time.zone.now
    end

    it 'responds only with grade descriptors created or updated after a certain time' do
      create :grade_descriptor, created_at: 3.months.ago, updated_at: 3.months.ago
      create :grade_descriptor, created_at: 2.months.ago, updated_at: 2.months.ago
      create :grade_descriptor, created_at: 4.months.ago, updated_at: 3.months.ago

      get :index, format: :json, params: { after_timestamp: 1.day.ago }

      expect(json['grade_descriptors'].length).to eq 3
    end

    it 'responds only with grade descriptors in a particular skill' do
      get :index, format: :json, params: { skill_id: @skill1.id }

      expect(json['grade_descriptors'].length).to eq 2
      expect(json['grade_descriptors'].map { |g| g['id'] }).to include @gd1.id, @gd2.id
    end

    it 'responds only with non-deleted grade_descriptors' do
      get :index, format: :json, params: { exclude_deleted: true }

      expect(json['grade_descriptors'].length).to eq 2
      expect(json['grade_descriptors'].map { |s| s['id'] }).to include @gd2.id, @gd3.id
    end
  end

  describe '#show' do
    before :each do
      @gd = create :grade_descriptor

      get :show, format: :json, params: { id: @gd.id }
    end

    it { should respond_with 200 }

    it 'responds with a particular grade descriptor' do
      expect(json['grade_descriptor']['id']).to eq @gd.id
      expect(json['grade_descriptor']['mark']).to eq @gd.mark
      expect(json['grade_descriptor']['grade_description']).to eq @gd.grade_description
    end

    it 'responds with timestamp' do
      expect(Time.zone.parse(json['meta']['timestamp'])).to be_within(1.second).of Time.zone.now
    end
  end
end
