# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::GroupsController, type: :controller do
  let(:json) { JSON.parse(response.body) }
  let(:group) { JSON.parse(response.body)['group'] }
  let(:groups) { JSON.parse(response.body)['groups'] }
  let(:admin) { create :admin }

  before :each do
    sign_in admin
  end

  describe '#index' do
    before :each do
      @chapter1 = create :chapter
      @chapter2 = create :chapter

      @group1 = create :group, chapter: @chapter1
      @group2 = create :group, chapter: @chapter2
      @group3 = create :group, deleted_at: Time.zone.now, chapter: @chapter1

      @student1 = create :student, group: @group1
      @student2 = create :student, group: @group1

      get :index, format: :json
    end

    it { should respond_with 200 }

    it 'gets a list of groups' do
      expect(response).to be_success
      expect(groups.map { |g| g['id'] }).to include @group1.id, @group2.id, @group3.id
      expect(groups.map { |g| g['group_name'] }).to include @group1.group_name, @group2.group_name, @group3.group_name
    end

    it 'responds with timestamp' do
      expect(Time.zone.parse(json['meta']['timestamp'])).to be_within(1.second).of Time.zone.now
    end

    it 'responds only with groups created or updated after a certain time' do
      create :group, created_at: 3.months.ago, updated_at: 3.months.ago
      create :group, created_at: 2.months.ago, updated_at: 2.months.ago
      create :group, created_at: 4.months.ago, updated_at: 3.months.ago

      get :index, format: :json, params: { after_timestamp: 1.day.ago }

      expect(groups.length).to eq 3
    end

    it 'responds only with non-deleted groups' do
      get :index, format: :json, params: { exclude_deleted: true }

      expect(groups.length).to eq 2
      expect(groups.map { |g| g['id'] }).to include @group1.id, @group2.id
    end

    it 'responds only with groups belonging to a specific chapter' do
      get :index, format: :json, params: { chapter_id: @chapter1.id }

      expect(groups.length).to eq 2
      expect(groups.map { |g| g['id'] }).to include @group1.id, @group3.id
    end
  end

  describe '#show' do
    before :each do
      @chapter = create :chapter
      @group = create :group, chapter: @chapter
      @student1 = create :student, group: @group
      @student2 = create :student, group: @group
      @lesson1 = create :lesson, group: @group
      @lesson2 = create :lesson, group: @group

      get :show, params: { id: @group.id }, format: :json
    end

    it 'gets a single group' do
      expect(response).to be_success
      expect(group['group_name']).to eq @group.group_name
      expect(group['chapter_id']).to eq @chapter.id
    end

    it 'responds with timestamp' do
      expect(Time.zone.parse(json['meta']['timestamp'])).to be_within(1.second).of Time.zone.now
    end

    describe 'include' do
      it 'includes a chapter' do
        get :show, params: { id: @group.id, include: 'chapter' }, format: :json

        expect(group['chapter']['id']).to eq @chapter.id
        expect(group['chapter']['chapter_name']).to eq @chapter.chapter_name
      end

      it 'includes students' do
        get :show, params: { id: @group.id, include: 'students' }, format: :json

        expect(group['students'].length).to eq 2
        expect(group['students'].map { |s| s['id'] }).to include @student1.id, @student2.id
        expect(group['students'].map { |s| s['first_name'] }).to include @student1.first_name, @student2.first_name
      end

      it 'includes lessons' do
        get :show, params: { id: @group.id, include: 'lessons' }, format: :json

        expect(group['lessons'].length).to eq 2
        expect(group['lessons'].map { |l| l['id'] }).to include @lesson1.id, @lesson2.id
      end
    end
  end
end
