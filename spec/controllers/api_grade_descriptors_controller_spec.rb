# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::GradeDescriptorsController, type: :controller do
  let(:json) { JSON.parse(response.body) }

  describe '#index' do
    before :each do
      @gd1 = create :grade_descriptor
      @gd2 = create :grade_descriptor
      @gd3 = create :grade_descriptor

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