require 'rails_helper'

RSpec.describe SubjectsController, type: :controller do
  context 'as a global administrator' do
    let(:user) { create :admin }

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

    describe '#create' do
      context 'Creates the subject successfully' do
        before :each do
          @org = create :organization
          post :create, params: { subject: {
            subject_name: 'Created Subject II',
            organization_id: @org.id
          } }
        end

        it { should redirect_to subjects_path }
        it { should set_flash[:notice].to 'Subject "Created Subject II" successfully created.' }

        it 'Creates the subject' do
          created_subject = Subject.last

          expect(created_subject.subject_name).to eq 'Created Subject II'
          expect(created_subject.organization).to eq @org
        end
      end

      it 'Rejects the subject' do
        post :create, params: { subject: {
          subject_name: 'Created Subject III'
        } }

        expect(response).to render_template 'subjects/index'
      end
    end
  end
end
