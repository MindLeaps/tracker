# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Chapter API', type: :request do
  include_context 'super_admin_request'

  let(:chapter) { JSON.parse(response.body)['chapter'] }
  let(:chapters) { JSON.parse(response.body)['chapters'] }
  let(:groups) { JSON.parse(response.body)['chapter']['groups'] }

  describe 'GET /chapters/:id' do
    before :each do
      @org = create :organization
      @chapter = create :chapter, organization: @org

      @group1, @group2 = create_list :group, 2, chapter: @chapter
    end

    it 'responds with a specific chapter' do
      get_with_token chapter_path(@chapter), as: :json

      expect(chapter['id']).to eq @chapter.id
      expect(chapter['chapter_name']).to eq @chapter.chapter_name
      expect(chapter['organization_id']).to eq @org.id
    end

    it 'responds with timestamp' do
      get_with_token chapter_path(@chapter), as: :json

      expect(response_timestamp).to be_within(1.second).of Time.zone.now
    end

    it 'responds with a specific chapter including groups' do
      get_with_token chapter_path(@chapter), params: { include: 'groups' }, as: :json

      expect(chapter['id']).to eq @chapter.id
      expect(groups.map { |g| g['id'] }).to include @group1.id, @group2.id
      expect(groups.map { |g| g['group_name'] }).to include @group1.group_name, @group2.group_name
    end
  end

  describe 'GET /chapters' do
    before :each do
      @org1, @org2 = create_list :organization, 2
      @chapter1, @chapter2 = create_list :chapter, 2, organization: @org1
      @chapter3 = create :chapter, deleted_at: Time.zone.now, organization: @org2
    end

    it 'responds with a list of chapters' do
      get_with_token chapters_path, as: :json

      expect(chapters.map { |c| c['id'] }).to include @chapter1.id, @chapter2.id, @chapter3.id
      expect(chapters.map { |c| c['chapter_name'] }).to include @chapter1.chapter_name, @chapter2.chapter_name, @chapter3.chapter_name
    end

    it 'responds with timestamp' do
      get_with_token chapters_path, as: :json

      expect(response_timestamp).to be_within(1.second).of Time.zone.now
    end

    it 'responds only with chapters created or updated after a certain time' do
      create :chapter, created_at: 3.months.ago, updated_at: 3.months.ago
      create :chapter, created_at: 2.months.ago, updated_at: 2.months.ago
      create :chapter, created_at: 4.months.ago, updated_at: 3.months.ago

      get_with_token chapters_path, params: { after_timestamp: 1.day.ago }, as: :json

      expect(chapters.length).to eq 3
    end

    it 'responds only with non-deleted chapters' do
      get_with_token chapters_path, params: { exclude_deleted: true }, as: :json

      expect(chapters.length).to eq 2
      expect(chapters.map { |g| g['id'] }).to include @chapter1.id, @chapter2.id
    end

    it 'responds only with chapters belonging to a specific organization' do
      get_with_token chapters_path, params: { organization_id: @org1.id }, as: :json

      expect(chapters.length).to eq 2
      expect(chapters.map { |g| g['id'] }).to include @chapter1.id, @chapter2.id
    end
  end
end
