require 'rails_helper'

RSpec.describe LessonsController, type: :controller do
  context 'as a global administrator' do
    let(:user) { create :global_admin }

    before :each do
      sign_in user
    end

    describe '#index' do
      before :each do
        @group = create :group
        @active_student1 = create :enrolled_student, organization: @group.chapter.organization, groups: [@group]
        @lesson1 = create :lesson, group: @group
        @lesson2 = create :lesson, group: @group

        get :index
      end

      it { should respond_with 200 }
      it { should render_template 'index' }

      it 'Lists existing lessons' do
        expect(assigns(:lesson_rows).map(&:id)).to include @lesson1.reload.id, @lesson2.reload.id
      end
    end

    describe '#show' do
      before :each do
        @group = create :group
        @active_student1 = create :enrolled_student, organization: @group.chapter.organization, groups: [@group]
        @active_student2 = create :enrolled_student, organization: @group.chapter.organization, groups: [@group]
        @deleted_student = create :enrolled_student, organization: @group.chapter.organization, groups: [@group], deleted_at: Time.zone.now

        lesson = create :lesson, group: @group, date: Time.zone.today
        gd1 = create :grade_descriptor, skill: lesson.subject.skills[0], mark: 1
        gd2 = create :grade_descriptor, skill: lesson.subject.skills[1], mark: 2
        gd3 = create :grade_descriptor, skill: lesson.subject.skills[2], mark: 3
        create :grade, lesson:, student: @active_student1, grade_descriptor: gd1
        create :grade, lesson:, student: @active_student1, grade_descriptor: gd2

        create :grade, lesson:, student: @active_student2, grade_descriptor: gd1
        create :grade, lesson:, student: @active_student2, grade_descriptor: gd2
        create :grade, lesson:, student: @active_student2, grade_descriptor: gd3
        get :show, params: { id: lesson.id }
      end

      it { should respond_with 200 }
      it { should render_template 'show' }

      it 'exposes non-deleted students from the lesson\'s group' do
        expect(assigns(:student_lesson_summaries).map(&:first_name)).to include @active_student1.first_name, @active_student2.first_name
        expect(assigns(:student_lesson_summaries).map(&:first_name)).not_to include @deleted_student.first_name
      end

      it 'calculates the correct average marks' do
        expect(assigns(:student_lesson_summaries).map(&:average_mark)).to include 1.5, 2.0
      end
    end

    describe '#new' do
      before :each do
        get :new
      end

      it { should respond_with 200 }
      it { should render_template 'new' }
      it 'exposes a new empty lesson' do
        expect(assigns(:lesson)).to be_instance_of Lesson
      end
    end

    describe '#edit' do
      before :each do
        @lesson = create :lesson
        get :edit, params: { id: @lesson.id }
      end

      it { should respond_with 200 }
      it { should render_template 'edit' }
      it 'presents a lesson to edit' do
        expect(assigns(:lesson)).to eq @lesson
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

        it { should redirect_to lesson_path Lesson.last }
        it { should set_flash[:success_notice] }

        it 'creates the Lesson' do
          created_lesson = Lesson.last

          expect(created_lesson.group).to eq @group
          expect(created_lesson.subject).to eq @subject
        end
      end

      context 'Tries to create an already existing lesson' do
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

        it { should render_template :new }
        it { should respond_with :unprocessable_entity }
        it { should set_flash[:failure_notice] }
      end

      context 'Tries to create a lesson with missing fields' do
        before :each do
          post :create, params: { lesson: {
            group_id: nil,
            subject_id: nil,
            date: ''
          } }
        end

        it { should render_template :new }
        it { should respond_with :unprocessable_entity }
        it { should set_flash[:failure_notice] }
      end
    end

    describe '#update' do
      before :each do
        @lesson = create :lesson
      end

      context 'success' do
        before :each do
          post :update, params: { id: @lesson.id, lesson: { group_id: @lesson.group_id, subject_id: @lesson.subject_id, date: 1.day.from_now } }
        end

        it { should respond_with 302 }
        it { should redirect_to lesson_url }
        it { should set_flash[:success_notice] }

        it 'updates the lesson' do
          expect(@lesson.reload.date).to eq 1.day.from_now.to_date
        end
      end

      context 'failure' do
        before :each do
          post :update, params: { id: @lesson.id, lesson: { group_id: @lesson.group_id, subject_id: @lesson.subject_id, date: nil } }
        end

        it { should respond_with 422 }
        it { should render_template :edit }
        it 'does not update the lesson' do
          expect(@lesson.reload.date).not_to eq 1.day.from_now.to_date
        end
      end
    end
  end
end
