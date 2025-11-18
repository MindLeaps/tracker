require 'rails_helper'

RSpec.describe SkillsController, type: :controller do
  context 'as a global administrator' do
    let(:user) { create :global_admin }

    before :each do
      sign_in user
    end

    describe '#index' do
      before :each do
        org = create :organization
        @skill1 = create :skill, skill_name: 'Memorization', organization: org
        @skill2 = create :skill, skill_name: 'Teamwork', organization: org
        @deleted_skill = create :skill, skill_name: 'Grit', organization: org, deleted_at: Time.zone.now
      end

      it 'Lists existing skills' do
        get :index

        expect(assigns(:skills)).to include @skill1, @skill2
      end

      it 'does not include deleted skill' do
        get :index

        expect(assigns(:skills)).not_to include @deleted_skill
      end

      it 'includes deleted skill when the exclude_deleted is set to false' do
        get :index, params: { exclude_deleted: false }

        expect(assigns(:skills)).to include @skill1, @skill2, @deleted_skill
      end

      context 'search' do
        before :each do
          get :index, params: { search: 'team' }
        end

        it 'Lists only Teamwork skill' do
          expect(assigns(:skills).length).to eq 1
          expect(assigns(:skills)).to include @skill2
        end
      end
    end

    describe '#create' do
      context 'Creates the lesson successfully' do
        before :each do
          @org = create :organization, organization_name: 'Skills Controller Spec Org'

          post :create, params: { skill: {
            organization_id: @org.id,
            skill_name: 'Skills Controller Spec Skill',
            skill_description: 'This is a test skill for controller unit test'
          } }
        end

        it 'creates the skill with grade descriptors' do
          post :create, params: { skill: {
            organization_id: @org.id,
            skill_name: 'Skills Controller Spec Skill II',
            skill_description: 'This is a second test skill for controller unit test',
            grade_descriptors_attributes: {
              '12345': { mark: '1', grade_description: 'grade mark one' },
              '54321': { mark: '2', grade_description: 'grade mark two' }
            }
          } }

          created_skill = Skill.last

          expect(created_skill.skill_name).to eq 'Skills Controller Spec Skill II'
          expect(created_skill.organization.organization_name).to eq 'Skills Controller Spec Org'
          expect(created_skill.skill_description).to eq 'This is a second test skill for controller unit test'
          expect(created_skill.grade_descriptors.map(&:mark)).to include 1, 2
          expect(created_skill.grade_descriptors.map(&:grade_description))
            .to include 'grade mark one', 'grade mark two'
        end

        it { should redirect_to Skill.last }
        it { should set_flash[:success_notice] }
      end
      context 'Lesson creation unsuccessful' do
        before :each do
          post :create, params: { skill: {
            skill_name: 'failed'
          } }
        end

        it { should render_template :new }
        it { should respond_with :unprocessable_content }
        it { should set_flash[:failure_notice] }
      end
    end

    describe '#show' do
      before :each do
        @skill1 = create :skill
        @skill2 = create :skill

        get :show, params: { id: @skill1.id }
      end

      it { should respond_with 200 }
      it { should render_template 'show' }
      it 'assigns the correct subject' do
        expect(assigns(:skill)).to eq @skill1

        get :show, params: { id: @skill2.id }
        expect(assigns(:skill)).to eq @skill2
      end
    end

    describe '#new' do
      before :each do
        get :new
      end

      it { should respond_with 200 }
      it { should render_template 'new' }
      it 'assigns the new empty skill' do
        expect(assigns(:skill)).to be_kind_of(Skill)
      end
    end

    describe '#destroy' do
      context 'Skill that has no grade and does not belong to a subject' do
        before :each do
          @skill = create :skill
          delete :destroy, params: {
            id: @skill.id
          }
        end

        it { should redirect_to skills_path }
        it { should set_flash[:success_notice] }

        it 'deletes the skill' do
          expect(@skill.reload.deleted_at).not_to be_nil
        end
      end

      context 'Skill that belongs to a Subject but has no grades' do
        before :each do
          subject = create :subject
          @skill = create(:skill_in_subject, subject:)
          request.env['HTTP_REFERER'] = 'http://example.com/skills?param=1'

          delete :destroy, params: {
            id: @skill.id
          }
        end

        it { should redirect_to 'http://example.com/skills?param=1' }

        it { should set_flash[:failure_notice] }

        it 'does not delete the skill' do
          expect(@skill.reload.deleted_at).to be_nil
        end
      end

      context 'Skill does not belong to a subject but has grades' do
        before :each do
          @skill = create :skill
          gd = create :grade_descriptor, skill: @skill
          create :grade, grade_descriptor: gd
          request.env['HTTP_REFERER'] = 'http://example.com/skills?param=1'
          delete :destroy, params: {
            id: @skill.id
          }
        end

        it { should redirect_to 'http://example.com/skills?param=1' }

        it { should set_flash[:failure_notice] }

        it 'does not delete the skill' do
          expect(@skill.reload.deleted_at).to be_nil
        end
      end
    end

    describe '#undelete' do
      before :each do
        @skill = create :skill, deleted_at: Time.zone.now
        request.env['HTTP_REFERER'] = 'http://example.com/skills?param=1'

        post :undelete, params: { id: @skill.id }
      end

      it { should redirect_to 'http://example.com/skills?param=1' }

      it { should set_flash[:success_notice] }

      it 'Marks the skill as not deleted' do
        expect(@skill.reload.deleted_at).to be_nil
      end
    end
  end
end
