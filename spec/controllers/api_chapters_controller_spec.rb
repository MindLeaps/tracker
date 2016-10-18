# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::ChaptersController, type: :controller do
  let(:json) { JSON.parse(response.body) }
  let(:chapters) { JSON.parse(response.body)['chapters'] }
  let(:chapter) { JSON.parse(response.body)['chapter'] }

  describe '#index' do
    before :each do
      @chapter1 = create :chapter
      @chapter2 = create :chapter
      @chapter3 = create :chapter

      @group1 = create :group, chapter: @chapter1
      @group2 = create :group, chapter: @chapter1

      get :index, format: :json
    end

    it { should respond_with 200 }

    it 'gets a list of chapters' do
      expect(response).to be_success
      expect(chapters.map { |g| g['chapter_name'] }).to include @chapter1.chapter_name, @chapter2.chapter_name, @chapter3.chapter_name
    end

    it 'responds with timestamp' do
      expect(Time.zone.parse(json['meta']['timestamp'])).to be_within(1.second).of Time.zone.now
    end
  end

  describe '#show' do
    before :each do
      @chapter = create :chapter

      @group1 = create :group, chapter: @chapter
      @group2 = create :group, chapter: @chapter

      get :show, params: { id: @chapter.id }, format: :json
    end

    it { should respond_with 200 }

    it 'gets a single chapter' do
      expect(response).to be_success
      expect(chapter['chapter_name']).to eq @chapter.chapter_name
    end

    it 'responds with timestamp' do
      expect(Time.zone.parse(json['meta']['timestamp'])).to be_within(1.second).of Time.zone.now
    end
  end
end
