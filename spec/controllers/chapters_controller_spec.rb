require 'rails_helper'

RSpec.describe ChaptersController, type: :controller do
  let(:admin) { create :global_admin }
  let(:test_organization) { create :organization, organization_name: 'Newly Created Test Org' }

  before :each do
    sign_in admin
  end

  describe '#index' do
    it 'gets a list of chapters' do
      chapter1 = create :chapter
      chapter2 = create :chapter

      get :index
      expect(response).to be_successful

      expect(assigns(:chapters).map(&:chapter_name)).to include chapter1.chapter_name, chapter2.chapter_name
    end
  end

  describe '#new' do
    before :each do
      get :new
    end

    it { should respond_with 200 }
    it { should render_template 'new' }
    it 'assigns the new empty chapter' do
      expect(assigns(:chapter)).to be_kind_of(Chapter)
    end
  end

  describe '#create' do
    context 'supplied valid params' do
      it 'creates a chapter' do
        post :create, params: { chapter: { chapter_name: 'Rugerero', organization_id: test_organization.id, mlid: 'Z9' } }
        expect(response).to redirect_to controller: :chapters, action: :index

        chapter = Chapter.last
        expect(chapter.chapter_name).to eql 'Rugerero'
        expect(chapter.mlid).to eql 'Z9'
        expect(chapter.organization_id).to eql test_organization.id
        expect(chapter.organization.organization_name).to eql 'Newly Created Test Org'
      end
    end

    context 'supplied no name' do
      before :each do
        @existing_chapter = create :chapter
        post :create, params: { chapter: { organization_id: test_organization.id } }
      end

      it { should render_template :new }
      it { should set_flash[:failure_notice] }
    end
  end

  describe '#edit' do
    before :each do
      @chapter = create :chapter

      get :edit, params: { id: @chapter.id }
    end

    it { should respond_with 200 }

    it 'presents a chapter to edit' do
      expect(assigns(:chapter)).to eq @chapter
    end
  end

  describe '#update' do
    before :each do
      @org1 = create :organization
      @org2 = create :organization
      @chapter = create :chapter, chapter_name: 'Test Chapter', organization: @org1
    end

    context 'success' do
      before :each do
        post :update, params: { id: @chapter.id, chapter: { chapter_name: 'Updated Name', organization_id: @org2.id } }
      end

      it { should respond_with 302 }

      it { should redirect_to chapter_url }

      it { should set_flash[:success_notice] }

      it 'updates the existing chapter' do
        expect(@chapter.reload.chapter_name).to eq 'Updated Name'
        expect(@chapter.reload.organization).to eq @org2
      end
    end

    context 'failure' do
      before :each do
        post :update, params: { id: @chapter.id, chapter: { chapter_name: '' } }
      end

      it { should render_template :edit }
      it { should respond_with 422 }
    end
  end

  describe '#destroy' do
    before :each do
      @chapter = create :chapter
      request.env['HTTP_REFERER'] = 'http://example.com/chapters?param=1'

      @groups = create_list :group, 2, chapter: @chapter
      @students = create_list :enrolled_student, 2, organization: @groups.first.chapter.organization, groups: [@groups.first]
      @lessons = create_list :lesson, 2, group: @groups.first
      @grades = create_list :grade, 2, lesson: @lessons.first
      @deleted_group = create :group, chapter: @chapter, deleted_at: Time.zone.now

      post :destroy, params: { id: @chapter.id }
    end

    it { should redirect_to 'http://example.com/chapters?param=1' }

    it { should set_flash[:success_notice] }

    it 'Marks the chapter as deleted' do
      expect(@chapter.reload.deleted_at).to be_within(1.second).of Time.zone.now
    end

    it 'Marks the chapter\'s dependents as deleted' do
      @chapter.reload

      @groups.each { |group| expect(group.reload.deleted_at).to eq(@chapter.deleted_at) }
      @lessons.each { |lesson| expect(lesson.reload.deleted_at).to eq(@chapter.deleted_at) }
      @grades.each { |grade| expect(grade.reload.deleted_at).to eq(@chapter.deleted_at) }
    end

    it 'Does not mark previously deleted dependents of the chapter as deleted' do
      @chapter.reload
      @deleted_group.reload

      expect(@deleted_group.deleted_at).to_not eq(@chapter.deleted_at)
    end
  end

  describe '#undelete' do
    before :each do
      @chapter = create :chapter, deleted_at: Time.zone.now

      @groups = create_list :group, 2, chapter: @chapter, deleted_at: @chapter.deleted_at
      @lessons = create_list :lesson, 2, group: @groups.first, deleted_at: @chapter.deleted_at
      @grades = create_list :grade, 2, lesson: @lessons.first, deleted_at: @chapter.deleted_at
      @deleted_group = create :group, chapter: @chapter, deleted_at: Time.zone.now

      post :undelete, params: { id: @chapter.id }
    end

    it { should set_flash[:success_notice] }

    it 'Removes the chapter\'s deleted timestamp' do
      expect(@chapter.reload.deleted_at).to be_nil
    end

    it 'Removes the chapter\'s dependents deleted timestamps' do
      @groups.each { |group| expect(group.reload.deleted_at).to be_nil }
      @lessons.each { |lesson| expect(lesson.reload.deleted_at).to be_nil }
      @grades.each { |grade| expect(grade.reload.deleted_at).to be_nil }
    end

    it 'Does not remove the previously deleted dependents of the chapter\'s deleted timestamp' do
      @deleted_group.reload

      expect(@deleted_group.deleted_at).to_not be_nil
    end
  end
end
