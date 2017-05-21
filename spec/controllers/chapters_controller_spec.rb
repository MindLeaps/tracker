# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChaptersController, type: :controller do
  let(:admin) { create :admin }
  let(:test_organization) { create :organization, organization_name: 'Newly Created Test Org' }

  before :each do
    sign_in admin
  end

  describe '#index' do
    it 'gets a list of chapters' do
      chapter1 = create :chapter
      chapter2 = create :chapter

      get :index
      expect(response).to be_success

      expect(assigns(:chapters)).to include chapter1
      expect(assigns(:chapters)).to include chapter2
    end
  end

  describe '#create' do
    context 'supplied valid params' do
      it 'creates a chapter' do
        post :create, params: { chapter: { chapter_name: 'Rugerero', organization_id: test_organization.id } }
        expect(response).to redirect_to controller: :chapters, action: :index

        chapter = Chapter.last
        expect(chapter.chapter_name).to eql 'Rugerero'
        expect(chapter.organization_id).to eql test_organization.id
        expect(chapter.organization.organization_name).to eql 'Newly Created Test Org'
      end
    end

    context 'supplied no name' do
      before :each do
        @existing_chapter = create :chapter
        post :create, params: { chapter: { organization_id: test_organization.id } }
      end

      it { should render_template :index }
      it 'Assigns the chapters for index rendering' do
        expect(assigns[:chapters]).to include @existing_chapter
      end
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

      it { should set_flash[:notice].to 'Chapter "Updated Name" updated.' }

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
end
