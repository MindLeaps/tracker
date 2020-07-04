# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TagPolicy do
  describe 'scope' do
    describe 'resolve_for_organization_id' do
      let(:org1) { create :organization }
      let(:org2) { create :organization }
      let(:current_user) { create :admin_of, organization: org1 }
      subject(:result) { TagPolicy::Scope.new(current_user, Tag).resolve_for_organization_id(org1.id) }

      it 'scopes to organization and shared tags' do
        shared_tags = create_list :tag, 3
        org1_tag = create :tag, organization: org1, shared: false
        org2_tag = create :tag, organization: org2, shared: false
        expect(result).to include(shared_tags[0], shared_tags[1], shared_tags[2])
        expect(result).to include(org1_tag)
        expect(result).not_to include(org2_tag)
      end
    end

    describe 'resolve' do
      let(:org1) { create :organization }
      let(:org2) { create :organization }
      let(:shared_tags) { create_list :tag, 3 }
      let(:org1_tag) { create :tag, organization: org1, shared: false }
      let(:org2_tag) { create :tag, organization: org2, shared: false }
      subject(:result) { TagPolicy::Scope.new(current_user, Tag).resolve }

      context 'user is a super administrator' do
        let(:current_user) { create :super_admin }

        it 'includes all tags' do
          expect(result).to include shared_tags[0], shared_tags[1], shared_tags[2], org1_tag, org2_tag
        end
      end

      context 'user is an administrator of one organization' do
        let(:current_user) { create :admin_of, organization: org1 }

        it 'includes all tags' do
          expect(result).to include shared_tags[0], shared_tags[1], shared_tags[2], org1_tag
          expect(result).not_to include org2_tag
        end
      end
    end
  end
end
