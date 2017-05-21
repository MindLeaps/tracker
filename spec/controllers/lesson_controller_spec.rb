# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LessonsController, type: :controller do
  context 'as a global administrator' do
    let(:user) { create :admin }

    before :each do
      sign_in user
    end

    describe '#index' do
      before :each do
        @lesson1 = create :lesson
        @lesson2 = create :lesson

        get :index
      end

      it { should respond_with 200 }
      it { should render_template 'index' }

      it 'Lists existing lessons' do
        expect(assigns(:lessons)).to include @lesson1, @lesson2
      end
    end

    describe '#show' do
      before :each do
        @group = create :group
        @active_student1 = create :student, group: @group
        @active_student2 = create :student, group: @group
        @deleted_student = create :student, group: @group, deleted_at: Time.zone.now

        lesson = create :lesson, group: @group
        get :show, params: { id: lesson.id }
      end

      it { should respond_with 200 }
      it { should render_template 'show' }

      it 'exposes non-deleted students from the lesson\'s group' do
        expect(assigns(:students)).to include @active_student1, @active_student2
        expect(assigns(:students)).not_to include @deleted_student
      end
    end

    describe '#create' do
      context 'Creates the lesson successfully' do
        before :each do
          @group = create :group
          @subject = create :subject

          post :create, params: { lesson: {
            group_id: @group.id,
            subject_id: @subject.id,
            date: Time.zone.today
          } }
        end

        it { should redirect_to lessons_path }
        it { should set_flash[:notice].to 'Lesson created.' }

        it 'creates the Lesson' do
          created_lesson = Lesson.last

          expect(created_lesson.group).to eq @group
          expect(created_lesson.subject).to eq @subject
        end
      end
      context 'Tries to create an existing lesson' do
        before :each do
          @group = create :group
          @subject = create :subject

          create :lesson, group: @group, subject: @subject, date: Time.zone.today

          post :create, params: { lesson: {
            group_id: @group.id,
            subject_id: @subject.id,
            date: Time.zone.today
          } }
        end

        it { should render_template :index }
      end
    end
  end
end
