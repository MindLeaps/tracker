# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::SubjectsController, type: :controller do
  let(:admin) { create :global_admin }

  before :each do
    sign_in admin
  end

  describe '#index' do
    before :each do
      create_list :subject, 3
      get :index, format: :json
    end

    it { should respond_with 200 }
  end

  describe '#show' do
    before :each do
      subject = create :subject

      get :show, format: :json, params: { id: subject.id }
    end

    it { should respond_with 200 }
  end
end
