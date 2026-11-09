require 'rails_helper'

RSpec.describe DashboardsController, type: :controller do
  render_views

  let(:organization) { create :organization }
  let(:chapter) { create :chapter, organization: }
  let(:user) { create :teacher_in, organization: }

  around do |example|
    previous = described_class.raise_on_missing_callback_actions
    described_class.raise_on_missing_callback_actions = true
    example.run
  ensure
    described_class.raise_on_missing_callback_actions = previous
  end

  before { sign_in user }

  it 'requires authentication' do
    sign_out user
    get :show
    expect(response).to have_http_status(:redirect)
  end

  it 'offers profile setup without silently selecting a chapter' do
    chapter
    get :show
    expect(response).to have_http_status(:ok)
    expect(response.body).to have_link('Choose my chapter', href: profile_path)
    expect(assigns(:dashboard)).to be_nil
  end

  it 'renders an accessible preferred chapter and empty states' do
    user.update!(preferred_chapter: chapter)
    get :show
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Your week in #{chapter.chapter_name}", 'No repeated declines', 'No active groups')
    expect(response.body).to have_link('Change working chapter', href: profile_path)
    expect(response.body).to have_link('Students', href: students_path)
    expect(response.body).to have_css('script[src*="new_charts"][onload]', visible: :all)
  end

  it 'rejects a preference after access is revoked' do
    user.update!(preferred_chapter: chapter)
    user.roles.clear
    get :show
    expect(assigns(:chapter)).to be_nil
    expect(response.body).not_to include(chapter.chapter_name)
  end

  it 'rejects deleted chapters and organizations' do
    user.update!(preferred_chapter: chapter)
    chapter.update!(deleted_at: Time.current)
    get :show
    expect(assigns(:chapter)).to be_nil
    chapter.update!(deleted_at: nil)
    organization.update!(deleted_at: Time.current)
    get :show
    expect(assigns(:chapter)).to be_nil
  end

  it 'supports global users without exposing an unselected chapter' do
    sign_in create(:global_guest, preferred_chapter: chapter)
    get :show
    expect(assigns(:chapter)).to eq chapter
  end
end
