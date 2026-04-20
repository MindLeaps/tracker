require 'rails_helper'

RSpec.describe Api::LessonsController, type: :controller do
  let(:lesson) { response.parsed_body['lesson'] }
  let(:admin) { create :global_admin }

  before :each do
    sign_in admin
  end

  describe '#index' do
    before :each do
      create_list :lesson, 3
      get :index, format: :json
    end

    it { should respond_with 200 }
  end

  describe '#show' do
    before :each do
      @lesson = create :lesson
      get :show, params: { id: @lesson.id }, format: :json
    end

    it { should respond_with 200 }
  end

  describe '#create' do
    before :each do
      @subject = create :subject
      @group = create :group
    end

    context 'creating a new lesson' do
      before :each do
        post :create, format: :json, params: { group_id: @group.id, subject_id: @subject.id, date: Time.zone.today.to_fs }
      end

      it { should respond_with 201 }

      it 'has a Location header with the resource URL' do
        expect(response.headers['Location']).to eq api_lesson_url id: Lesson.last.id
      end
    end

    context 'lesson already exists with the same ID' do
      before :each do
        @existing_lesson = create :lesson, group_id: @group.id, subject_id: @subject.id, date: Time.zone.today.to_fs
        post :create, format: :json, params: { id: @existing_lesson.id, group_id: @group.id, subject_id: @subject.id, date: Time.zone.today.to_fs }
      end

      it { should respond_with 200 }

      it 'responds with the existing lesson' do
        expect(lesson['id']).to eq @existing_lesson.id
      end
    end

    context 'lesson already exists with a different ID' do
      before :each do
        @existing_lesson = create :lesson, group_id: @group.id, subject_id: @subject.id, date: Time.zone.today.to_fs
        post :create, format: :json, params: { id: 'bbbe6756-1737-4660-b7e5-e95ae0600124', group_id: @group.id, subject_id: @subject.id, date: Time.zone.today.to_fs }
      end

      it { should respond_with :conflict }

      it 'responds with the conflicting lesson' do
        expect(lesson['id']).to eq @existing_lesson.id
      end
    end

    context 'lesson cannot be created for a non-duplicate reason' do
      before :each do
        post :create, format: :json, params: { id: 'bbbe6756-1737-4660-b7e5-e95ae0600124', group_id: @group.id, date: Time.zone.today.to_fs }
      end

      it { should respond_with :unprocessable_content }
    end
  end
end
