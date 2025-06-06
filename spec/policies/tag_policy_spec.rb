require 'rails_helper'

RSpec.describe TagPolicy do
  describe 'permissions' do
    subject { TagPolicy.new current_user, tag }

    context 'as a Super Administrator' do
      let(:current_user) { create :super_admin }

      context 'on a Tag Resource' do
        let(:tag) { Tag }

        it { is_expected.to permit_action :index }
        it { is_expected.to permit_action :create }
      end

      context 'on any existing tag' do
        let(:tag) { create :tag }

        it { is_expected.to permit_action :show }
        it { is_expected.to permit_action :destroy }
        it { is_expected.to permit_action :edit }
        it { is_expected.to permit_action :update }
      end
    end

    context 'as a Global Administrator' do
      let(:current_user) { create :global_admin }

      context 'on a Tag Resource' do
        let(:tag) { Tag }

        it { is_expected.to permit_action :index }
        it { is_expected.to permit_action :create }
      end

      context 'on any existing tag' do
        let(:tag) { create :tag }

        it { is_expected.to permit_action :show }
        it { is_expected.to permit_action :destroy }
        it { is_expected.to permit_action :edit }
        it { is_expected.to permit_action :update }
      end
    end

    context 'as a Global Guest' do
      let(:current_user) { create :global_guest }

      context 'on a Tag Resource' do
        let(:tag) { Tag }

        it { is_expected.to permit_action :index }
        it { is_expected.not_to permit_action :create }
      end

      context 'on any existing tag' do
        let(:tag) { create :tag }

        it { is_expected.to permit_action :show }
        it { is_expected.not_to permit_action :destroy }
        it { is_expected.not_to permit_action :edit }
        it { is_expected.not_to permit_action :update }
      end
    end

    context 'as a Global Researcher' do
      let(:current_user) { create :global_researcher }

      context 'on a Tag Resource' do
        let(:tag) { Tag }

        it { is_expected.to permit_action :index }
        it { is_expected.not_to permit_action :create }
      end

      context 'on any existing tag' do
        let(:tag) { create :tag }

        it { is_expected.to permit_action :show }
        it { is_expected.not_to permit_action :destroy }
        it { is_expected.not_to permit_action :edit }
        it { is_expected.not_to permit_action :update }
      end
    end

    context 'as a Local Administrator' do
      let(:org) { create :organization }
      let(:current_user) { create :admin_of, organization: org }

      context 'on a Tag Resource' do
        let(:tag) { Tag }

        it { is_expected.not_to permit_action :index }
      end

      context 'on a tag inside own\'s organization' do
        let(:tag) { create :tag, organization: org }

        it { is_expected.to permit_action :show }
        it { is_expected.to permit_action :destroy }
        it { is_expected.to permit_action :edit }
        it { is_expected.to permit_action :update }
      end

      context 'on a tag outside of own\'s organization' do
        let(:tag) { create :tag, organization: create(:organization) }

        it { is_expected.not_to permit_action :show }
        it { is_expected.not_to permit_action :destroy }
        it { is_expected.not_to permit_action :edit }
        it { is_expected.not_to permit_action :update }
      end
    end

    context 'as a Local Teacher' do
      let(:org) { create :organization }
      let(:current_user) { create :teacher_in, organization: org }

      context 'on a Tag Resource' do
        let(:tag) { Tag }

        it { is_expected.not_to permit_action :index }
      end

      context 'on a tag inside own\'s organization' do
        let(:tag) { create :tag, organization: org }

        it { is_expected.to permit_action :show }
        it { is_expected.not_to permit_action :destroy }
        it { is_expected.not_to permit_action :edit }
        it { is_expected.not_to permit_action :update }
      end

      context 'on a tag outside of own\'s organization' do
        let(:tag) { create :tag, organization: create(:organization) }

        it { is_expected.not_to permit_action :show }
        it { is_expected.not_to permit_action :destroy }
        it { is_expected.not_to permit_action :edit }
        it { is_expected.not_to permit_action :update }
      end
    end

    context 'as a Local Guest' do
      let(:org) { create :organization }
      let(:current_user) { create :guest_in, organization: org }

      context 'on a Tag Resource' do
        let(:tag) { Tag }

        it { is_expected.not_to permit_action :index }
      end

      context 'on a tag inside own\'s organization' do
        let(:tag) { create :tag, organization: org }

        it { is_expected.to permit_action :show }
        it { is_expected.not_to permit_action :destroy }
        it { is_expected.not_to permit_action :edit }
        it { is_expected.not_to permit_action :update }
      end

      context 'on a tag outside of own\'s organization' do
        let(:tag) { create :tag, organization: create(:organization) }

        it { is_expected.not_to permit_action :show }
        it { is_expected.not_to permit_action :destroy }
        it { is_expected.not_to permit_action :edit }
        it { is_expected.not_to permit_action :update }
      end
    end

    context 'as a Local Researcher' do
      let(:org) { create :organization }
      let(:current_user) { create :researcher_in, organization: org }

      context 'on a Tag Resource' do
        let(:tag) { Tag }

        it { is_expected.not_to permit_action :index }
      end

      context 'on a tag inside own\'s organization' do
        let(:tag) { create :tag, organization: org }

        it { is_expected.to permit_action :show }
        it { is_expected.not_to permit_action :destroy }
        it { is_expected.not_to permit_action :edit }
        it { is_expected.not_to permit_action :update }
      end

      context 'on a tag outside of own\'s organization' do
        let(:tag) { create :tag, organization: create(:organization) }

        it { is_expected.not_to permit_action :show }
        it { is_expected.not_to permit_action :destroy }
        it { is_expected.not_to permit_action :edit }
        it { is_expected.not_to permit_action :update }
      end
    end
  end

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
