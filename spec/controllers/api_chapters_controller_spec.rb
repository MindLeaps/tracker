# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::ChaptersController, type: :controller do
  let(:json) { JSON.parse(response.body) }
  before :each do
    @chapter1 = create :chapter, chapter_name: 'Chapter Api Test Chapter One'
    @chapter2 = create :chapter, chapter_name: 'Chapter Api Test Chapter Two'
    @chapter3 = create :chapter, chapter_name: 'Chapter Api Test Chapter Three'

    @group1 = create :group, chapter: @chapter1
    @group2 = create :group, chapter: @chapter1
  end

  describe '#index' do
    it 'gets a list of chapters' do
      get :index, format: :json
      expect(response).to be_success
      expect(json.map { |g| g['chapter_name'] }).to include 'Chapter Api Test Chapter One',
                                                            'Chapter Api Test Chapter Two',
                                                            'Chapter Api Test Chapter Three'
    end
  end

  describe '#show' do
    it 'gets a single chapter' do
      get :show, params: { id: @chapter1.id }, format: :json
      expect(response).to be_success
      expect(json['chapter_name']).to eq @chapter1.chapter_name
      expect(json['groups'].map { |g| g['id'] }).to include(@group1.id, @group2.id)
    end
  end
end
