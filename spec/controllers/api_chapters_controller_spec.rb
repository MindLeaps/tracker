# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::ChaptersController, type: :controller do
  let(:json) { JSON.parse(response.body) }
  let(:chapters) { JSON.parse(response.body)['chapters'] }
  let(:chapter) { JSON.parse(response.body)['chapter'] }

  describe '#index' do
    before :each do
      @org1 = create :organization
      @org2 = create :organization

      @chapter1 = create :chapter, organization: @org1
      @chapter2 = create :chapter, organization: @org1, deleted_at: Time.zone.now
      @chapter3 = create :chapter, organization: @org2

      @group1 = create :group, chapter: @chapter1
      @group2 = create :group, chapter: @chapter1

      get :index, format: :json
    end

    it { should respond_with 200 }

    it 'gets a list of chapters' do
      expect(response).to be_success
      expect(chapters.map { |g| g['id'] }).to include @chapter1.id, @chapter2.id, @chapter3.id
      expect(chapters.map { |g| g['chapter_name'] }).to include @chapter1.chapter_name, @chapter2.chapter_name, @chapter3.chapter_name
    end

    it 'responds with timestamp' do
      expect(Time.zone.parse(json['meta']['timestamp'])).to be_within(1.second).of Time.zone.now
    end

    it 'responds only with chapters created or updated after a certain time' do
      create :chapter, created_at: 2.months.ago, updated_at: 2.days.ago
      create :chapter, created_at: 2.months.ago, updated_at: 5.days.ago
      create :chapter, created_at: 5.days.ago, updated_at: 6.hours.ago

      get :index, format: :json, params: { after_timestamp: 1.day.ago }

      expect(chapters.length).to eq 4
    end

    it 'responds only with chapters belonging to a certain organization' do
      get :index, format: :json, params: { organization_id: @org1.id }

      expect(chapters.length).to eq 2
      expect(chapters.map { |c| c['chapter_name'] }).to include @chapter1.chapter_name, @chapter2.chapter_name
    end

    it 'responds without deleted chapters' do
      get :index, format: :json, params: { exclude_deleted: true }

      expect(chapters.length).to eq 2
      expect(chapters.map { |c| c['id'] }).to include @chapter1.id, @chapter3.id
    end
  end

  describe '#show' do
    before :each do
      @org = create :organization

      @chapter = create :chapter, organization: @org

      @group1 = create :group, chapter: @chapter
      @group2 = create :group, chapter: @chapter

      get :show, params: { id: @chapter.id }, format: :json
    end

    it { should respond_with 200 }

    it 'gets a single chapter' do
      expect(response).to be_success
      expect(chapter['id']).to eq @chapter.id
      expect(chapter['chapter_name']).to eq @chapter.chapter_name
      expect(chapter['organization_id']).to eq @chapter.organization_id
    end

    it 'responds with timestamp' do
      expect(Time.zone.parse(json['meta']['timestamp'])).to be_within(1.second).of Time.zone.now
    end

    describe 'include' do
      it 'includes the organization' do
        get :show, format: :json, params: { id: @chapter.id, include: 'organization' }

        expect(chapter['organization']['id']).to eq @org['id']
        expect(chapter['organization']['organization_name']).to eq @org['organization_name']
      end

      it 'includes the groups' do
        get :show, format: :json, params: { id: @chapter.id, include: 'groups' }

        expect(chapter['groups'].map { |g| g['id'] }).to include @group1.id, @group2.id
        expect(chapter['groups'].map { |g| g['group_name'] }).to include @group1.group_name, @group2.group_name
      end
    end
  end
end
