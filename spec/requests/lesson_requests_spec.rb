require 'rails_helper'

RSpec.describe 'Lesson API', type: :request do
  include_context 'super_admin_request'

  let(:lesson) { json['lesson'] }
  let(:lessons) { json['lessons'] }
  let(:group) { json['lesson']['group'] }
  let(:subject) { json['lesson']['subject'] }

  describe 'GET /lessons/:id' do
    before :each do
      @group = create :group
      @subject = create :subject
      @lesson = create :lesson, group: @group, subject: @subject
    end

    it 'responds with a specific lesson' do
      get_with_token lesson_path(@lesson), as: :json

      expect(lesson['id']).to eq @lesson.id
      expect(lesson['group_id']).to eq @lesson.group_id
      expect(lesson['subject_id']).to eq @lesson.subject_id
      expect(lesson['date']).to eq @lesson.date.to_s
    end

    it 'responds with timestamp' do
      get_with_token lesson_path(@lesson), as: :json

      expect(response_timestamp).to be_within(1.second).of Time.zone.now
    end

    it 'responds with a specific lesson including group' do
      get_with_token lesson_path(@lesson), params: { include: 'group' }, as: :json

      expect(group['id']).to eq @group.id
      expect(group['group_name']).to eq @group.group_name
    end

    it 'responds with a specific lesson including subject' do
      get_with_token lesson_path(@lesson), params: { include: 'subject' }, as: :json

      expect(subject['id']).to eq @subject.id
      expect(subject['subject_name']).to eq @subject.subject_name
    end

    describe 'v2' do
      it 'responds with a specific lesson by UUID' do
        get_v2_with_token lesson_path(id: @lesson.reload.uid), as: :json

        expect(lesson['id']).to eq @lesson.uid
        expect(lesson['group_id']).to eq @lesson.group_id
        expect(lesson['subject_id']).to eq @lesson.subject_id
        expect(lesson['date']).to eq @lesson.date.to_s
      end
    end
  end

  describe 'GET /lessons' do
    before :each do
      @group1 = create :group
      @group2 = create :group
      @subject1 = create :subject
      @subject2 = create :subject
      @lesson1, @lesson2 = create_list :lesson, 2, subject: @subject1, group: @group1, deleted_at: Time.zone.now
      @lesson3 = create :lesson, subject: @subject2, group: @group2
    end

    it 'responds with a list of lessons' do
      get_with_token lessons_path, as: :json

      expect(lessons.length).to eq 3
      expect(lessons.pluck('id')).to include @lesson1.id, @lesson2.id, @lesson3.id
    end

    it 'responds with timestamp' do
      get_with_token lessons_path, as: :json
      expect(response_timestamp).to be_within(1.second).of Time.zone.now
    end

    it 'responds only with lessons created or updated after a certain time' do
      create :lesson, created_at: 3.months.ago, updated_at: 3.months.ago
      create :lesson, created_at: 2.months.ago, updated_at: 2.months.ago
      create :lesson, created_at: 4.months.ago, updated_at: 1.hour.ago

      get_with_token lessons_path, params: { after_timestamp: 1.day.ago }, as: :json

      expect(lessons.length).to eq 4
    end

    it 'responds only with lessons belonging to a specific group' do
      get_with_token lessons_path, params: { group_id: @group1.id }, as: :json

      expect(lessons.length).to eq 2
      expect(lessons.pluck('id')).to include @lesson1.id, @lesson2.id
    end

    it 'responds only with lessons in a specific subject' do
      get_with_token lessons_path, params: { subject_id: @subject1.id }, as: :json

      expect(lessons.length).to eq 2
      expect(lessons.pluck('id')).to include @lesson1.id, @lesson2.id
    end

    describe 'v2' do
      it 'responds with a list of lessons with UUIDs for IDs' do
        get_v2_with_token lessons_path, as: :json

        expect(response).to be_successful
        expect(lessons.length).to eq 3
        expect(lessons.pluck('id')).to include @lesson1.reload.uid, @lesson2.reload.uid, @lesson3.reload.uid
      end
    end
  end

  describe 'POST /lessons' do
    before :each do
      @subject = create :subject
      @group = create :group
    end

    context 'creating a new lesson' do
      before :each do
        post_with_token lessons_path, as: :json, params: { group_id: @group.id, subject_id: @subject.id, date: Time.zone.today.to_fs }
      end

      it 'creates a new lesson' do
        lesson = Lesson.last
        expect(lesson.subject_id).to eq @subject.id
        expect(lesson.group_id).to eq @group.id
        expect(lesson.date).to eq Time.zone.today
      end

      it 'has a Location header with the resource URL' do
        expect(response.headers['Location']).to eq api_lesson_url id: Lesson.last.id
      end
    end

    context 'lesson already exists' do
      before :each do
        create :lesson, group_id: @group.id, subject_id: @subject.id, date: Time.zone.today.to_fs
        post_with_token lessons_path, as: :json, params: { group_id: @group.id, subject_id: @subject.id, date: Time.zone.today.to_fs }
      end

      it 'responds with lesson' do
        expect(lesson['subject_id']).to eq @subject.id
        expect(lesson['group_id']).to eq @group.id
        expect(Time.zone.parse(lesson['date'])).to eq Time.zone.today
      end

      it 'does not save the new lesson' do
        expect(Lesson.all.length).to eq 1
      end
    end

    describe 'v2' do
      context 'creating a new lesson' do
        it 'creates a new lesson with the passed UUID' do
          post_v2_with_token lessons_path, as: :json, params: { id: '5e9d2b0e-1dc6-4c04-b70c-9d67c20b083e', group_id: @group.id, subject_id: @subject.id, date: Time.zone.today.to_fs }
          new_lesson = Lesson.last
          expect(new_lesson.uid).to eq '5e9d2b0e-1dc6-4c04-b70c-9d67c20b083e'
          expect(new_lesson.subject_id).to eq @subject.id
          expect(new_lesson.group_id).to eq @group.id
          expect(new_lesson.date).to eq Time.zone.today
          expect(lesson['id']).to eq '5e9d2b0e-1dc6-4c04-b70c-9d67c20b083e'
        end

        it 'creates a new lesson without the passed UUID' do
          post_v2_with_token lessons_path, as: :json, params: { group_id: @group.id, subject_id: @subject.id, date: Time.zone.today.to_fs }
          new_lesson = Lesson.last
          expect(new_lesson.subject_id).to eq @subject.id
          expect(new_lesson.group_id).to eq @group.id
          expect(new_lesson.date).to eq Time.zone.today
          expect(lesson['id']).to eq new_lesson.uid
        end

        it 'has a Location header with the resource URL' do
          post_v2_with_token lessons_path, as: :json, params: { id: '5e9d2b0e-1dc6-4c04-b70c-9d67c20b083e', group_id: @group.id, subject_id: @subject.id, date: Time.zone.today.to_fs }
          expect(response.headers['Location']).to eq api_lesson_url id: '5e9d2b0e-1dc6-4c04-b70c-9d67c20b083e'
        end
      end

      context 'lesson already exists' do
        before :each do
          @existing_lesson = create :lesson, uid: '5e9d2b0e-1dc6-4c04-b70c-9d67c20b083e', group_id: @group.id, subject_id: @subject.id, date: Time.zone.today.to_fs
          post_v2_with_token lessons_path, as: :json, params: { group_id: @group.id, subject_id: @subject.id, date: Time.zone.today.to_fs }
        end

        it 'responds with existing lesson' do
          expect(lesson['id']).to eq '5e9d2b0e-1dc6-4c04-b70c-9d67c20b083e'
          expect(lesson['subject_id']).to eq @subject.id
          expect(lesson['group_id']).to eq @group.id
          expect(Time.zone.parse(lesson['date'])).to eq Time.zone.today
        end
      end
    end
  end
end
