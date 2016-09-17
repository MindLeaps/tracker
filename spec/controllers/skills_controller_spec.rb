require 'rails_helper'

RSpec.describe SkillsController, type: :controller do
  context 'as a global administrator' do
    let(:user) { create :admin }

    before :each do
      sign_in user
    end

    describe '#index' do
      before :each do
        org = create :organization
        @skill1 = create :skill, skill_name: 'Memorization', organization: org
        @skill2 = create :skill, skill_name: 'Teamwork', organization: org
      end

      it 'Lists existing subjects' do
        get :index

        expect(assigns(:skills)).to include @skill1, @skill2
      end
    end

    describe '#create' do
      context 'Creates the lesson successfully' do
        before :each do
          org = create :organization, organization_name: 'Skills Controller Spec Org'

          post :create, params: { skill: {
            organization_id: org.id,
            skill_name: 'Skills Controller Spec Skill'
          } }
        end

        it 'creates the skill' do
          created_skill = Skill.last

          expect(created_skill.skill_name).to eq 'Skills Controller Spec Skill'
          expect(created_skill.organization.organization_name).to eq 'Skills Controller Spec Org'
        end

        it { should redirect_to skills_path }
        it { should set_flash[:notice].to 'Skill "Skills Controller Spec Skill" successfully created.' }
      end
    end
    context 'Lesson creation unsuccessful' do
      before :each do
        post :create, params: { skill: {
          skill_name: 'failed'
        } }
      end

      it { should render_template :index }
    end
  end
end
