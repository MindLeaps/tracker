# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::LessonsController, type: :controller do
  let(:json) { JSON.parse(response.body) }
  let(:lesson) { JSON.parse(response.body)['lesson'] }
  let(:admin) { create :admin }

  before :each do
    sign_in admin
  end

  describe '#index' do
    before :each do
      @subject1 = create :subject
      @subject2 = create :subject

      @group1 = create :group
      @group2 = create :group

      @lesson1 = create :lesson, group: @group1, subject: @subject1
      @lesson2 = create :lesson, group: @group1, subject: @subject2
      @lesson3 = create :lesson, group: @group2, subject: @subject2

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

    it 'responds only with lessons belonging to a specific group' do
      get :index, format: :json, params: { group_id: @group1.id }

      expect(json['lessons'].length).to eq 2
      expect(json['lessons'].map { |s| s['id'] }).to include @lesson1.id, @lesson2.id
    end

    it 'responds only with lessons belonging to a specific subject' do
      get :index, format: :json, params: { subject_id: @subject1.id }

      expect(json['lessons'].length).to eq 1
      expect(json['lessons'].map { |s| s['id'] }).to include @lesson1.id
    end
  end

  describe '#show' do
    before :each do
      @group = create :group
      @subject = create :subject
      @lesson = create :lesson, group: @group, subject: @subject
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

    describe 'include' do
      it 'includes group' do
        get :show, format: :json, params: { id: @lesson.id, include: 'group' }

        expect(lesson['group']['id']).to eq @group.id
        expect(lesson['group']['group_name']).to eq @group.group_name
      end

      it 'includes subject' do
        get :show, format: :json, params: { id: @lesson.id, include: 'subject' }

        expect(lesson['subject']['id']).to eq @subject.id
        expect(lesson['subject']['subject_name']).to eq @subject.subject_name
      end
    end
  end

  describe '#create' do
    before :each do
      @subject = create :subject
      @group = create :group
    end

    context 'creating a new lesson' do
      before :each do
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

    context 'lesson already exists' do
      before :each do
        create :lesson, group_id: @group.id, subject_id: @subject.id, date: Time.zone.today.to_formatted_s
        post :create, format: :json, params: { group_id: @group.id, subject_id: @subject.id, date: Time.zone.today.to_formatted_s }
      end

      it { should respond_with 200 }

      it 'responds with lesson' do
        expect(lesson['subject_id']).to eq @subject.id
        expect(lesson['group_id']).to eq @group.id
        expect(Time.zone.parse(lesson['date'])).to eq Time.zone.today
      end

      it 'does not save the new lesson' do
        expect(Lesson.all.length).to eq 1
      end
    end
  end
end
