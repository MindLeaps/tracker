# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrganizationPolicy do
  describe 'permissions' do
    subject { OrganizationPolicy.new current_user, org }

    context 'as a Super Administrator' do
      let(:current_user) { create :super_admin }

      context 'on an Organization Resource' do
        let(:org) { Organization }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing organization' do
        let(:org) { Organization.create }
        it { is_expected.to permit_action :show }
        it { is_expected.to permit_action :add_member }
      end

      context 'on a new organization' do
        let(:org) { build :organization }
        it { is_expected.to permit_action :create }
      end
    end

    context 'as a Global Administrator' do
      let(:current_user) { create :global_admin }

      context 'on an Organization Resource' do
        let(:org) { Organization }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing organization' do
        let(:org) { Organization.create }
        it { is_expected.to permit_action :show }
        it { is_expected.to permit_action :add_member }
      end

      context 'on a new organization' do
        let(:org) { build :organization }
        it { is_expected.to permit_action :create }
      end
    end

    context 'as a Global Guest' do
      let(:current_user) { create :global_guest }

      context 'on an Organization Resource' do
        let(:org) { Organization }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing organization' do
        let(:org) { Organization.create }
        it { is_expected.to permit_action :show }
        it { is_expected.to forbid_action :add_member }
      end

      context 'on a new organization' do
        let(:org) { build :organization }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Global Researcher' do
      let(:current_user) { create :global_researcher }

      context 'on an Organization Resource' do
        let(:org) { Organization }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing organization' do
        let(:org) { Organization.create }
        it { is_expected.to permit_action :show }
        it { is_expected.to forbid_action :add_member }
      end

      context 'on a new organization' do
        let(:org) { build :organization }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Local Administrator' do
      let(:org1) { create :organization }
      let(:current_user) { create :admin_of, organization: org1 }

      context 'on an Organization Resource' do
        let(:org) { Organization }
        it { is_expected.to permit_action :index }
      end

      context 'on the own organization' do
        let(:org) { org1 }
        it { is_expected.to permit_action :show }
        it { is_expected.to permit_action :add_member }
      end

      context 'on another organization' do
        let(:org) { create :organization }
        it { is_expected.to forbid_action :show }
        it { is_expected.to forbid_action :add_member }
      end

      context 'on a new organization' do
        let(:org) { build :organization }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Local Teacher' do
      let(:org1) { create :organization }
      let(:current_user) { create :teacher_in, organization: org1 }

      context 'on an Organization Resource' do
        let(:org) { Organization }
        it { is_expected.to permit_action :index }
      end

      context 'on the own organization' do
        let(:org) { org1 }
        it { is_expected.to permit_action :show }
        it { is_expected.to forbid_action :add_member }
      end

      context 'on another organization' do
        let(:org) { create :organization }
        it { is_expected.to forbid_action :show }
        it { is_expected.to forbid_action :add_member }
      end

      context 'on a new organization' do
        let(:org) { build :organization }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Local Guest' do
      let(:org1) { create :organization }
      let(:current_user) { create :guest_in, organization: org1 }

      context 'on an Organization Resource' do
        let(:org) { Organization }
        it { is_expected.to permit_action :index }
      end

      context 'on the own organization' do
        let(:org) { org1 }
        it { is_expected.to permit_action :show }
        it { is_expected.to forbid_action :add_member }
      end

      context 'on another organization' do
        let(:org) { create :organization }
        it { is_expected.to forbid_action :show }
        it { is_expected.to forbid_action :add_member }
      end

      context 'on a new organization' do
        let(:org) { build :organization }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Local Researcher' do
      let(:org1) { create :organization }
      let(:current_user) { create :researcher_in, organization: org1 }

      context 'on an Organization Resource' do
        let(:org) { Organization }
        it { is_expected.to permit_action :index }
      end

      context 'on the own organization' do
        let(:org) { org1 }
        it { is_expected.to permit_action :show }
        it { is_expected.to forbid_action :add_member }
      end

      context 'on another organization' do
        let(:org) { create :organization }
        it { is_expected.to forbid_action :show }
        it { is_expected.to forbid_action :add_member }
      end

      context 'on a new organization' do
        let(:org) { build :organization }
        it { is_expected.to forbid_action :create }
      end
    end
  end

  describe 'scope' do
    RSpec.shared_examples :global_user_organization_scope do
      subject(:result) { OrganizationPolicy::Scope.new(current_user, Organization).resolve }
      let(:org1) { create :organization }
      let(:org2) { create :organization }
      let(:org3) { create :organization }

      it 'returns all organizations' do
        expect(result).to include(org1, org2, org3)
      end
    end

    RSpec.shared_examples :local_user_organization_scope do
      subject(:result) { OrganizationPolicy::Scope.new(current_user, Organization).resolve }
      let(:org2) { create :organization }

      it 'includes organization where user has a role' do
        expect(result).to include(org)
      end

      it 'does not include organization in which user does not have a role' do
        expect(result).not_to include(org2)
      end
    end

    context 'As a Super Administrator' do
      let(:current_user) { create :super_admin }
      it_behaves_like :global_user_organization_scope
    end

    context 'As a Global Administrator' do
      let(:current_user) { create :global_admin }
      it_behaves_like :global_user_organization_scope
    end

    context 'As a Global Guest' do
      let(:current_user) { create :global_guest }
      it_behaves_like :global_user_organization_scope
    end

    context 'As a Global Researcher' do
      let(:current_user) { create :global_researcher }
      it_behaves_like :global_user_organization_scope
    end

    context 'As a Local Administrator' do
      let(:org) { create :organization }
      let(:current_user) { create :admin_of, organization: org }
      it_behaves_like :local_user_organization_scope
    end

    context 'As a Local Teacher' do
      let(:org) { create :organization }
      let(:current_user) { create :teacher_in, organization: org }
      it_behaves_like :local_user_organization_scope
    end

    context 'As a Local Guest' do
      let(:org) { create :organization }
      let(:current_user) { create :guest_in, organization: org }
      it_behaves_like :local_user_organization_scope
    end

    context 'As a Local Researcher' do
      let(:org) { create :organization }
      let(:current_user) { create :researcher_in, organization: org }
      it_behaves_like :local_user_organization_scope
    end

    context 'As a User with roles in multiple organizations' do
      subject(:result) { OrganizationPolicy::Scope.new(current_user, Organization).resolve }

      let(:org1) { create :organization }
      let(:org2) { create :organization }
      let(:org3) { create :organization }
      let(:current_user) do
        u = create :admin_of, organization: org1
        u.add_role :teacher, org2
        u
      end

      it 'includes both organizations where user has a role' do
        expect(result).to include(org1, org2)
      end

      it 'does not include an organization where user does not have a role' do
        expect(result).not_to include(org3)
      end
    end
  end
end
