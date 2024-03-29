require 'rails_helper'

RSpec.describe Api::AssignmentsController, type: :controller do
  let(:admin) { create :global_admin }

  before :each do
    sign_in admin
  end

  describe '#index' do
    before :each do
      create_list :assignment, 3
      get :index, format: :json
    end

    it { should respond_with 200 }
  end

  describe '#show' do
    before :each do
      @a = create :assignment

      get :show, format: :json, params: { id: @a.id }
    end

    it { should respond_with 200 }
  end
end
