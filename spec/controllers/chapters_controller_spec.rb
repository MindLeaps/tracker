require 'rails_helper'

RSpec.describe ChaptersController, type: :controller do
  fixtures :organizations, :chapters, :groups
  include_context 'controller_login'
  let(:test_organization) { organizations(:good_test_organization) }

  describe '#index' do
    it 'gets a list of chapters' do
      get :index
      expect(response).to be_success

      expect(assigns(:chapters)).to include chapters(:kigali_chapter)
    end
  end

  describe '#new' do
    it 'creates a chapter when supplied valid params' do
      post :create, params: { chapter: { chapter_name: 'Rugerero', organization_id: test_organization.id } }
      expect(response).to redirect_to controller: :chapters, action: :index

      chapter = Chapter.last
      expect(chapter.chapter_name).to eql 'Rugerero'
      expect(chapter.organization_id).to eql test_organization.id
    end
  end
end
