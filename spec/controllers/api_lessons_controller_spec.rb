# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::LessonsController, type: :controller do
  let(:json) { JSON.parse(response.body) }
  let(:lesson) { JSON.parse(response.body)['lesson'] }

  describe '#index' do
    before :each do
      @lesson1 = create :lesson
      @lesson2 = create :lesson
      @lesson3 = create :lesson

      @lesson_ids = [@lesson1.id, @lesson2.id, @lesson3.id]
      get :index, format: :json
    end

    it { should respond_with 200 }

    it 'gets a list of all lessons' do
      expect(json['lessons'].map { |l| l['id'] }).to include(*@lesson_ids)
    end

    it 'responds with timestamp' do
      expect(Time.zone.parse(json['meta']['timestamp'])).to be_within(1.second).of Time.zone.now
    end

    it 'responds only with lessons created or updated after a certain time' do
      create :lesson, created_at: 3.months.ago, updated_at: 3.months.ago
      create :lesson, created_at: 2.months.ago, updated_at: 2.months.ago
      create :lesson, created_at: 4.months.ago, updated_at: 3.months.ago

      get :index, format: :json, params: { after_timestamp: 1.day.ago }

      expect(json['lessons'].length).to eq 3
    end
  end

  describe '#show' do
    before :each do
      @lesson = create :lesson
      get :show, params: { id: @lesson.id }, format: :json
    end

    it { should respond_with 200 }

    it 'gets a single lesson' do
      expect([lesson['id'], lesson['group_id'], lesson['subject_id'], lesson['date']]).to eq [
        @lesson.id, @lesson.group_id, @lesson.subject_id, @lesson.date.to_formatted_s
      ]
    end

    it 'responds with timestamp' do
      expect(Time.zone.parse(json['meta']['timestamp'])).to be_within(1.second).of Time.zone.now
    end
  end

  describe '#create' do
    before :each do
      @subject = create :subject
      @group = create :group

      post :create, format: :json, params: { group_id: @group.id, subject_id: @subject.id, date: Time.zone.today.to_formatted_s }
    end

    it 'creates a new lesson' do
      lesson = Lesson.last
      expect(lesson.subject_id).to eq @subject.id
      expect(lesson.group_id).to eq @group.id
      expect(lesson.date).to eq Time.zone.today
    end

    it { should respond_with 201 }

    it 'has a Location header with the resource URL' do
      expect(response.headers['Location']).to eq api_lesson_url id: Lesson.last.id
    end
  end
end
