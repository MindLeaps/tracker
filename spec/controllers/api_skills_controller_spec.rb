# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::SkillsController, type: :controller do
  let(:json) { JSON.parse(response.body) }

  describe '#index' do
    before :each do
      @skill1 = create :skill
      @skill2 = create :skill

      get :index, format: :json
    end

    it { should respond_with 200 }

    it 'responds with a list of skills' do
      expect(json['skills'].length).to eq 2
      expect(json['skills'].map { |s| s['id'] }).to include @skill1.id, @skill2.id
      expect(json['skills'].map { |s| s['skill_name'] }).to include @skill1.skill_name, @skill2.skill_name
      expect(json['skills'].map { |s| s['skill_description'] }).to include @skill1.skill_description, @skill2.skill_description
      expect(json['skills'].map { |s| s['organization_id'] }).to include @skill1.organization_id, @skill2.organization_id
    end
  end

  describe '#show' do
    before :each do
      @skill = create :skill

      get :show, format: :json, params: { id: @skill.id }
    end

    it { should respond_with 200 }

    it 'responds with a skill' do
      expect(json['skill']['id']).to eq @skill.id
      expect(json['skill']['skill_name']).to eq @skill.skill_name
      expect(json['skill']['skill_description']).to eq @skill.skill_description
      expect(json['skill']['organization_id']).to eq @skill.organization_id
    end
  end
end
