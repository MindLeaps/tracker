# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::GroupsController, type: :controller do
  let(:group) { JSON.parse(response.body)['group'] }
  let(:groups) { JSON.parse(response.body)['groups'] }
  let(:admin) { create :admin }

  before :each do
    sign_in admin
  end

  describe '#index' do
    before :each do
      create_list :group, 3
      get :index, format: :json
    end

    it { should respond_with 200 }
  end

  describe '#show' do
    before :each do
      group = create :group
      get :show, format: :json, params: { id: group.id }
    end

    it { should respond_with 200 }
  end
end
