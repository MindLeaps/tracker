require 'rails_helper'

RSpec.describe Api::SkillsController, type: :controller do
  let(:admin) { create :global_admin }

  before :each do
    sign_in admin
  end

  describe '#index' do
    before :each do
      create_list :skill, 3

      get :index, format: :json
    end

    it { should respond_with 200 }
  end

  describe '#show' do
    before :each do
      @skill = create :skill

      get :show, format: :json, params: { id: @skill.id }
    end

    it { should respond_with 200 }
  end
end
