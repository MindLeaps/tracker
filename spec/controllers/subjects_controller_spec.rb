# frozen_string_literal: true

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
      before :each do
        @subject = create :subject_with_skills, subject_name: 'Test Subject', number_of_skills: 2
        @new_skill = create :skill
        post :update, params: { id: @subject.id, subject: {
          subject_name: 'Updated Name',
          organization_id: @subject.organization_id,
          assignments_attributes: [
            { id: @subject.assignments[0].id, skill_id: @subject.assignments[0].skill_id, _destroy: false },
            { id: @subject.assignments[0].id, skill_id: @subject.assignments[1].skill_id, _destroy: false },
            { skill_id: @new_skill.id }
          ]
        } }
      end

      it { should redirect_to subject_path @subject }
      it 'updates the subject name' do
        expect(@subject.reload.subject_name).to eq 'Updated Name'
      end
      it 'updates the subject skills' do
        expect(@subject.reload.skills.length).to eq 3
        expect(@subject.skills).to include @new_skill
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

        it { should redirect_to subjects_path }
        it { should set_flash[:notice].to 'Subject "Created Subject I" created.' }

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

      context 'Rejects the subject' do
        it 'and renders the index template' do
          post :create, params: { subject: {
            subject_name: 'Created Subject III'
          } }

          expect(response).to render_template 'subjects/index'
        end
      end
    end
  end
end
