# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::ChaptersController, type: :controller do
  let(:chapters) { JSON.parse(response.body)['chapters'] }
  let(:chapter) { JSON.parse(response.body)['chapter'] }
  let(:admin) { create :admin }

  before :each do
    sign_in admin
  end

  describe '#index' do
    before :each do
      create_list :chapter, 3
      get :index, format: :json
    end

    it { should respond_with 200 }
  end

  describe '#show' do
    before :each do
      chapter = create :chapter
      get :show, params: { id: chapter.id }, format: :json
    end

    it { should respond_with 200 }
  end
end
