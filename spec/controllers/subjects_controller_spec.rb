require 'rails_helper'

RSpec.describe SubjectsController, type: :controller do
  context 'as a global administrator' do
    let(:user) { create :global_admin }

    before :each do
      sign_in user
    end

    describe '#index' do
      before :each do
        org = create :organization
        @subject1 = create :subject, subject_name: 'Memorization', organization: org
        @subject2 = create :subject, subject_name: 'Teamwork', organization: org
      end

      it 'Lists existing subjects' do
        get :index

        expect(assigns(:subjects)).to include @subject1, @subject2
      end
    end

    describe '#show' do
      before :each do
        @subject = create :subject_with_skills, number_of_skills: 3
        get :show, params: { id: @subject.id }
      end

      it { should respond_with 200 }
      it { should render_template 'show' }

      it 'shows the selected subject' do
        expect(assigns(:subject)).to eq @subject
      end
    end

    describe '#edit' do
      before :each do
        @subject = create :subject_with_skills, number_of_skills: 3
        get :edit, params: { id: @subject.id }
      end

      it { should respond_with 200 }
      it { should render_template 'edit' }
      it 'shows the subject for editing' do
        expect(assigns(:subject)).to eq @subject
      end
    end

    describe '#update' do
      context 'updates subject' do
        before :each do
          @subject = create :subject_with_skills, subject_name: 'Test Subject', number_of_skills: 2
          @new_skill = create :skill
          post :update, params: { id: @subject.id, subject: {
            subject_name: 'Updated Name',
            organization_id: @subject.organization_id,
            assignments_attributes: {
              0 => { id: @subject.assignments[0].id, skill_id: @subject.assignments[0].skill_id, _destroy: false },
              1 => { id: @subject.assignments[0].id, skill_id: @subject.assignments[1].skill_id, _destroy: false },
              2 => { skill_id: @new_skill.id }
            }
          } }
        end

        it { should redirect_to subject_path @subject }
        it { should set_flash[:success_notice] }
        it 'updates the subject name' do
          expect(@subject.reload.subject_name).to eq 'Updated Name'
        end
        it 'updates the subject skills' do
          expect(@subject.reload.skills.length).to eq 3
          expect(@subject.skills).to include @new_skill
        end
      end

      context 'does not update subject' do
        before :each do
          @subject_with_graded_skill = create :subject_with_skills, subject_name: 'Test Subject', number_of_skills: 1
          @lesson_using_subject = create :lesson, subject: @subject_with_graded_skill
          @grade_in_lesson = create :grade, lesson: @lesson_using_subject, skill: @subject_with_graded_skill.skills.first

          post :update, params: { id: @subject_with_graded_skill.id, subject: {
            subject_name: 'With removed but used skill',
            organization_id: @subject_with_graded_skill.organization_id,
            assignments_attributes: {
              0 => { id: @subject_with_graded_skill.assignments[0].id, skill_id: @subject_with_graded_skill.assignments[0].skill_id, _destroy: '1' }
            }
          } }
        end

        it { should redirect_to subject_path @subject_with_graded_skill }
        it { should set_flash[:failure_notice] }
        it 'does not remove the skill' do
          expect(@subject_with_graded_skill.reload.skills.length).to eq 1
        end
      end

      context 'Requests additional skill' do
        before :each do
          @subject = create :subject_with_skills, subject_name: 'Test Subject', number_of_skills: 2
          post :update, params: {
            id: @subject.id,
            subject: {
              subject_name: ''
            },
            add_skill: 'Add Skill'
          }
        end

        it { should render_template :new }
        it { should respond_with :ok }
      end
    end

    describe '#new' do
      before :each do
        get :new
      end

      it { should respond_with 200 }
      it { should render_template :new }
      it 'assigns a new empty subject' do
        expect(assigns(:subject)).to be_kind_of(Subject)
      end
    end

    describe '#create' do
      context 'Creates the subject successfully' do
        before :each do
          @org = create :organization
          post :create, params: { subject: {
            subject_name: 'Created Subject I',
            organization_id: @org.id
          } }
        end

        it { should redirect_to subject_path Subject.last }
        it { should set_flash[:success_notice] }

        it 'Creates the subject without skills' do
          created_subject = Subject.last

          expect(created_subject.subject_name).to eq 'Created Subject I'
          expect(created_subject.organization).to eq @org
        end

        it 'Creates the subject with skills' do
          @skill1 = create :skill, skill_name: 'Subject Controller Spec Skill I'
          @skill2 = create :skill, skill_name: 'Subject Controller Spec Skill II'
          create :skill, skill_name: 'Subject Controller Spec Skill III'

          post :create, params: { subject: {
            subject_name: 'Created Subject II',
            organization_id: @org.id,
            assignments_attributes: [
              { skill_id: @skill1.id },
              { skill_id: @skill2.id }
            ]
          } }

          created_subject = Subject.last

          expect(created_subject.subject_name).to eq 'Created Subject II'
          expect(created_subject.skills).to include @skill1, @skill2
        end
      end

      context 'Requests additional skill' do
        before :each do
          post :create, params: {
            subject: {
              subject_name: ''
            },
            add_skill: 'Add Skill'
          }
        end

        it { should render_template :new }
        it { should respond_with :ok }
      end

      context 'Rejects the subject' do
        before :each do
          post :create, params: { subject: {
            subject_name: 'Created Subject III'
          } }
        end
        it 'and renders the new template' do
          expect(response).to render_template :new
        end

        it { should set_flash[:failure_notice] }
      end
    end
  end
end
