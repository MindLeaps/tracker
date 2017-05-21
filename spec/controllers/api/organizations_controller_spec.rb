# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::OrganizationsController, type: :controller do
  let(:admin) { create :admin }

  before :each do
    sign_in admin
  end

  describe '#index' do
    before :each do
      create_list :organization, 3
      get :index, format: :json
    end

    it { should respond_with 200 }
  end

  describe '#show' do
    before :each do
      @org = create :organization

      get :show, format: :json, params: { id: @org.id }
    end

    it { should respond_with 200 }
  end
end
