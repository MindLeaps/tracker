require 'rails_helper'

RSpec.describe 'Group API', type: :request do
  include_context 'super_admin_request'

  let(:group) { response.parsed_body['group'] }
  let(:groups) { response.parsed_body['groups'] }
  let(:students) { response.parsed_body['group']['students'] }
  let(:lessons) { response.parsed_body['group']['lessons'] }

  describe 'GET /groups/:id' do
    before :each do
      @chapter = create :chapter
      @group = create :group, chapter: @chapter

      @student1, @student2 = create_list :enrolled_student, 2, organization: @chapter.organization, groups: [@group]
      @lesson1, @lesson2 = create_list :lesson, 2, group: @group
    end

    it 'responds with a specific group' do
      get_with_token group_path(@group), as: :json

      expect(group['group_name']).to eq @group.group_name
      expect(group['id']).to eq @group.id
    end

    it 'responds with timestamp' do
      get_with_token group_path(@group), as: :json

      expect(response_timestamp).to be_within(1.second).of Time.zone.now
    end

    it 'responds with a specific group including students' do
      get_with_token group_path(@group), params: { include: 'students' }, as: :json

      expect(group['id']).to eq @group.id
      expect(students.pluck('id')).to include @student1.id, @student2.id
      expect(students.pluck('first_name')).to include @student1.first_name, @student2.first_name
      expect(students.pluck('last_name')).to include @student1.last_name, @student2.last_name
    end

    it 'responds with a specific group including chapter' do
      get_with_token group_path(@group), params: { include: 'chapter' }, as: :json

      expect(group['id']).to eq @group.id
      expect(group['chapter']['id']).to eq @group.chapter.id
      expect(group['chapter']['chapter_name']).to eq @group.chapter.chapter_name
    end

    it 'responds with a specific group including lessons' do
      get_with_token group_path(@group), params: { include: 'lessons' }, as: :json

      expect(group['id']).to eq @group.id
      expect(lessons.pluck('id')).to include @lesson1.id, @lesson2.id
      expect(lessons.pluck('date')).to include @lesson1.date.to_s, @lesson2.date.to_s
    end
  end

  describe 'GET /groups' do
    before :each do
      @chapter1, @chapter2 = create_list :chapter, 2
      @group1, @group2 = create_list :group, 2, chapter: @chapter1
      @group3 = create :group, deleted_at: Time.zone.now, chapter: @chapter2
    end

    it 'responds with a list of groups' do
      get_with_token groups_path, as: :json

      expect(groups.pluck('id')).to include @group1.id, @group2.id
      expect(groups.pluck('group_name')).to include @group1.group_name, @group2.group_name
    end

    it 'responds with timestamp' do
      get_with_token groups_path, as: :json

      expect(response_timestamp).to be_within(1.second).of Time.zone.now
    end

    it 'responds only with groups created or updated after a certain time' do
      create :group, created_at: 3.months.ago, updated_at: 3.months.ago
      create :group, created_at: 2.months.ago, updated_at: 2.months.ago
      create :group, created_at: 4.months.ago, updated_at: 3.months.ago

      get_with_token groups_path, params: { after_timestamp: 1.day.ago }, as: :json

      expect(groups.length).to eq 3
    end

    it 'responds only with non-deleted groups' do
      get_with_token groups_path, params: { exclude_deleted: true }, as: :json

      expect(groups.length).to eq 2
      expect(groups.pluck('id')).to include @group1.id, @group2.id
    end

    it 'responds only with groups belonging to a specific chapter' do
      get_with_token groups_path, params: { chapter_id: @chapter1.id }, as: :json

      expect(groups.length).to eq 2
      expect(groups.pluck('id')).to include @group1.id, @group2.id
    end
  end
end
