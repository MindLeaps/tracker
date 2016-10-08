require 'rails_helper'

RSpec.describe Api::LessonsController, type: :controller do
  let(:json) { JSON.parse(response.body) }

  describe '#index' do
    before :all do
      @lesson1 = create :lesson
      @lesson2 = create :lesson
      @lesson3 = create :lesson

      @lesson_ids = [@lesson1.id, @lesson2.id, @lesson3.id]
    end

    it 'gets a list of all lessons' do
      get :index, format: :json

      expect(response).to be_success
      expect(json.map { |l| l['id'] }).to include(*@lesson_ids)
    end
  end

  describe '#get' do
    before :each do
      @lesson = create :lesson
      get :show, params: { id: @lesson.id }, format: :json
    end

    it { should respond_with 200 }

    it 'gets a single lesson' do
      expect([json['id'], json['group_id'], json['subject_id'], json['date']]).to eq [
        @lesson.id, @lesson.group_id, @lesson.subject_id, @lesson.date.to_formatted_s
      ]
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
