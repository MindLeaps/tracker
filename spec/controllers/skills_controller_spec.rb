# frozen_string_literal: true

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
        it { should set_flash[:notice].to 'Skill "Skills Controller Spec Skill" created.' }
      end
      context 'Lesson creation unsuccessful' do
        before :each do
          post :create, params: { skill: {
            skill_name: 'failed'
          } }
        end

        it { should render_template :new }
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
  end
end
