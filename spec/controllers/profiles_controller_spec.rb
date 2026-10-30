require 'rails_helper'

RSpec.describe ProfilesController, type: :controller do
  render_views

  let(:organization) { create :organization }
  let(:user) { create :teacher_in, organization: }
  let!(:chapter) { create :chapter, organization: }

  around do |example|
    previous_setting = described_class.raise_on_missing_callback_actions
    described_class.raise_on_missing_callback_actions = true
    example.run
  ensure
    described_class.raise_on_missing_callback_actions = previous_setting
  end

  before do
    sign_in user
  end

  describe 'GET show' do
    it 'shows the account and available chapters with the saved selection' do
      user.update!(preferred_chapter: chapter)
      get :show

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(user.email, organization.organization_name, chapter.chapter_name)
      expect(response.body).to have_css("select#profile_preferred_chapter_id option[value='#{chapter.id}'][selected]")
      expect(response.body).to have_css("img.rounded-full[src*='unknown_user'][width='128'][height='128']")
      expect(response.body).to have_css('nav a[disabled]', text: 'My profile')
    end

    it 'excludes other organizations and deleted chapters and organizations' do
      create :chapter
      create :chapter, organization:, deleted_at: Time.zone.now
      deleted_organization = create :organization, deleted_at: Time.zone.now
      user.add_role :teacher, deleted_organization
      create :chapter, organization: deleted_organization

      get :show

      expect(assigns(:available_chapters)).to eq [chapter]
    end

    it 'allows an account without roles to open its own profile' do
      user.roles.clear
      get :show

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t(:profile_no_chapters))
    end

    it 'allows global users to choose chapters across organizations' do
      other_chapter = create :chapter
      sign_in create(:global_guest)
      get :show

      expect(assigns(:available_chapters)).to contain_exactly(chapter, other_chapter)
    end

    it 'requires authentication' do
      sign_out user
      get :show

      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'PATCH update' do
    it 'persists a chapter for the signed-in user only' do
      other_chapter = create(:chapter, organization:)
      other_user = create :user

      patch :update, params: { profile: { preferred_chapter_id: other_chapter.id.to_s, user_id: other_user.id } }

      expect(response).to redirect_to(profile_path)
      expect(user.reload.preferred_chapter).to eq other_chapter
      expect(other_user.preferred_chapter).to be_nil
    end

    it 'clears the preference when no chapter is selected' do
      user.update!(preferred_chapter: chapter)
      patch :update, params: { profile: { preferred_chapter_id: '' } }

      expect(response).to redirect_to(profile_path)
      expect(user.reload.preferred_chapter).to be_nil
    end

    it 'rejects inaccessible chapters without partially changing preferences' do
      user.update!(preferred_chapter: chapter)
      inaccessible_chapter = create :chapter
      patch :update, params: { profile: { preferred_chapter_id: inaccessible_chapter.id.to_s } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t(:profile_invalid_chapter))
      expect(user.reload.preferred_chapter).to eq chapter
    end

    it 'rejects deleted chapters' do
      chapter.update!(deleted_at: Time.zone.now)
      patch :update, params: { profile: { preferred_chapter_id: chapter.id.to_s } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(user.reload.preferred_chapter).to be_nil
    end

    it 'rejects nonexistent chapters' do
      patch :update, params: { profile: { preferred_chapter_id: '999999999' } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(user.reload.preferred_chapter).to be_nil
    end

    it 'rejects chapters after organization membership is revoked' do
      user.update!(preferred_chapter: chapter)
      user.roles.clear
      patch :update, params: { profile: { preferred_chapter_id: chapter.id.to_s } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(assigns(:available_chapters)).to be_empty
    end
  end
end
