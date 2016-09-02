require 'rails_helper'

RSpec.describe ChaptersController, type: :controller do
  fixtures :chapters, :groups
  include_context 'controller_login'

  describe '#index' do
    it 'gets a list of chapters' do
      get :index
      expect(response).to be_success

      expect(assigns(:chapters)).to include chapters(:kigali_chapter)
    end
  end

  describe '#new' do
    it 'create a chapter when supplied valid params' do
      post :create, params: { chapter: { chapter_name: 'Rugerero' } }
      expect(response).to redirect_to controller: :chapters, action: :index

      chapter = Chapter.last
      expect(chapter.chapter_name).to eql 'Rugerero'
    end
  end
end
