# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::GroupsController, type: :controller do
  let(:json) { JSON.parse(response.body) }
  let(:group) { JSON.parse(response.body)['group'] }
  let(:groups) { JSON.parse(response.body)['groups'] }

  describe '#index' do
    before :each do
      @chapter = create :chapter

      @group1 = create :group, chapter: @chapter
      @group2 = create :group
      @group3 = create :group

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
  end

  describe '#show' do
    before :each do
      @chapter = create :chapter
      @group = create :group, chapter: @chapter

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
  end
end
