require 'rails_helper'

RSpec.describe ChaptersController, type: :controller do
  let (:admin) { create :admin }
  let (:test_organization) {create :organization, organization_name: 'Newly Created Test Org'}

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

  describe '#new' do
    it 'creates a chapter when supplied valid params' do
      post :create, params: { chapter: { chapter_name: 'Rugerero', organization_id: test_organization.id } }
      expect(response).to redirect_to controller: :chapters, action: :index

      chapter = Chapter.last
      expect(chapter.chapter_name).to eql 'Rugerero'
      expect(chapter.organization_id).to eql test_organization.id
      expect(chapter.organization.organization_name).to eql 'Newly Created Test Org'
    end
  end
end
