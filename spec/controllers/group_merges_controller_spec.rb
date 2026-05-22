require 'rails_helper'

RSpec.describe GroupMergesController, type: :controller do
  let(:organization) { create :organization }
  let(:chapter) { create :chapter, organization: }
  let(:destination_group) { create :group, chapter: }
  let(:source_group) { create :group, chapter: }

  describe '#new' do
    before do
      sign_in create(:admin_of, organization:)
    end

    it 'shows active groups for admins' do
      deleted_group = create :group, chapter:, deleted_at: Time.zone.now

      get :new, params: { destination_group_id: destination_group.id }

      expect(response).to be_successful
      expect(assigns(:destination_group)).to eq destination_group
      expect(assigns(:source_groups)).to include source_group
      expect(assigns(:source_groups)).not_to include destination_group
      expect(assigns(:source_groups)).not_to include deleted_group
    end
  end

  describe '#preview' do
    before do
      sign_in create(:admin_of, organization:)
    end

    it 'builds a directional preview' do
      post :preview, params: { group_merge: { source_group_id: source_group.id, destination_group_id: destination_group.id } }

      expect(response).to be_successful
      expect(assigns(:source_group)).to eq source_group
      expect(assigns(:destination_group)).to eq destination_group
      expect(assigns(:preview)).to be_a GroupMergePreview
    end

    it 'does not allow deleted groups' do
      source_group.update!(deleted_at: Time.zone.now)

      post :preview, params: { group_merge: { source_group_id: source_group.id, destination_group_id: destination_group.id } }

      expect(response).to have_http_status :unprocessable_content
      expect(response).to render_template :new
    end
  end

  describe 'authorization' do
    it 'does not allow teachers to preview a merge' do
      sign_in create(:teacher_in, organization:)

      post :preview, params: { group_merge: { source_group_id: source_group.id, destination_group_id: destination_group.id } }

      expect(response).to have_http_status :unauthorized
    end
  end
end
