# frozen_string_literal: true

require 'rails_helper'
RSpec.describe UserPolicy do
  describe 'permissions' do
    subject { UserPolicy.new current_user, user }

    context 'as a Super Administrator' do
      let(:current_user) { create :super_admin }

      context 'on a User Resource' do
        let(:user) { User }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing user' do
        let(:user) { User }
        it { is_expected.to permit_action :show }
      end

      context 'on a new user' do
        let(:user) { build :user }
        it { is_expected.to permit_action :create }
      end
    end

    context 'as a Global Administrator' do
      let(:current_user) { create :global_admin }

      context 'on a User Resource' do
        let(:user) { User }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing user' do
        let(:user) { User }
        it { is_expected.to permit_action :show }
      end

      context 'on a new user' do
        let(:user) { build :user }
        it { is_expected.to permit_action :create }
      end
    end

    context 'as a Global Guest' do
      let(:current_user) { create :global_guest }

      context 'on a User Resource' do
        let(:user) { User }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing user' do
        let(:user) { User }
        it { is_expected.to permit_action :show }
      end

      context 'on a new user' do
        let(:user) { build :user }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Global Researcher' do
      let(:current_user) { create :global_researcher }

      context 'on a User Resource' do
        let(:user) { User }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing user' do
        let(:user) { User }
        it { is_expected.to permit_action :show }
      end

      context 'on a new user' do
        let(:user) { build :user }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Local Administrator' do
      let(:org) { create :organization }
      let(:current_user) { create :admin_of, organization: org }

      context 'on a User Resource' do
        let(:user) { User }
        it { is_expected.to permit_action :index }
      end

      context 'on a user inside own\'s organization' do
        let(:user) { create :teacher_in, organization: org }
        it { is_expected.to permit_action :show }
      end

      context 'on a user outside of own\'s organization' do
        let(:user) { create :teacher_in, organization: create(:organization) }
        it { is_expected.to forbid_action :show }
      end

      context 'on a user outside of own\'s organization' do
        let(:user) { create :teacher_in, organization: create(:organization) }
        it { is_expected.to forbid_action :show }
      end

      context 'on a new user' do
        let(:user) { build :user }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Local Teacher' do
      let(:org) { create :organization }
      let(:current_user) { create :teacher_in, organization: org }

      context 'on a User Resource' do
        let(:user) { User }
        it { is_expected.to permit_action :index }
      end

      context 'on a user inside own\'s organization' do
        let(:user) { create :teacher_in, organization: org }
        it { is_expected.to permit_action :show }
      end

      context 'on a user outside of own\'s organization' do
        let(:user) { create :teacher_in, organization: create(:organization) }
        it { is_expected.to forbid_action :show }
      end

      context 'on a user outside of own\'s organization' do
        let(:user) { create :teacher_in, organization: create(:organization) }
        it { is_expected.to forbid_action :show }
      end

      context 'on a new user' do
        let(:user) { build :user }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Local Guest' do
      let(:org) { create :organization }
      let(:current_user) { create :guest_in, organization: org }

      context 'on a User Resource' do
        let(:user) { User }
        it { is_expected.to permit_action :index }
      end

      context 'on a user inside own\'s organization' do
        let(:user) { create :teacher_in, organization: org }
        it { is_expected.to permit_action :show }
      end

      context 'on a user outside of own\'s organization' do
        let(:user) { create :teacher_in, organization: create(:organization) }
        it { is_expected.to forbid_action :show }
      end

      context 'on a user outside of own\'s organization' do
        let(:user) { create :teacher_in, organization: create(:organization) }
        it { is_expected.to forbid_action :show }
      end

      context 'on a new user' do
        let(:user) { build :user }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Local Researcher' do
      let(:org) { create :organization }
      let(:current_user) { create :researcher_in, organization: org }

      context 'on a User Resource' do
        let(:user) { User }
        it { is_expected.to permit_action :index }
      end

      context 'on a user inside own\'s organization' do
        let(:user) { create :teacher_in, organization: org }
        it { is_expected.to permit_action :show }
      end

      context 'on a user outside of own\'s organization' do
        let(:user) { create :teacher_in, organization: create(:organization) }
        it { is_expected.to forbid_action :show }
      end

      context 'on a user outside of own\'s organization' do
        let(:user) { create :teacher_in, organization: create(:organization) }
        it { is_expected.to forbid_action :show }
      end

      context 'on a new user' do
        let(:user) { build :user }
        it { is_expected.to forbid_action :create }
      end
    end
  end

  describe 'scope' do
    RSpec.shared_examples :global_user_scope do
      subject(:result) { UserPolicy::Scope.new(current_user, User).resolve }
      let(:org1) { create :organization }
      let(:org2) { create :organization }
      let(:teachers_in_org1) { create_list :teacher_in, 3, organization: org1 }
      let(:teachers_in_org2) { create_list :teacher_in, 3, organization: org2 }
      let(:global_users) { create_list :global_guest, 3 }

      it 'returns all users from first organization' do
        expect(result).to include(*teachers_in_org1)
      end

      it 'returns all users from second organization' do
        expect(result).to include(*teachers_in_org2)
      end

      it 'includes global users' do
        expect(result).to include(*global_users)
      end

      it 'includes self' do
        expect(result).to include(current_user)
      end
    end

    RSpec.shared_examples :local_user_scope do
      subject(:result) { UserPolicy::Scope.new(current_user, User).resolve }
      let(:org2) { create :organization }
      let(:teachers_in_org) { create_list :teacher_in, 3, organization: org }
      let(:teachers_in_org2) { create_list :teacher_in, 3, organization: org2 }
      let(:global_users) { create_list :global_guest, 3 }

      it 'includes all users from the first organization' do
        expect(result).to include(*teachers_in_org)
      end

      it 'does not include users from the second organization' do
        expect(result).not_to include(*teachers_in_org2)
      end

      it 'does not include global users' do
        expect(result).not_to include(*global_users)
      end

      it 'includes self' do
        expect(result).to include(current_user)
      end
    end

    context 'As a Super Administrator' do
      let(:current_user) { create :super_admin }
      it_behaves_like :global_user_scope
    end

    context 'As a Global Administrator' do
      let(:current_user) { create :global_admin }
      it_behaves_like :global_user_scope
    end

    context 'As a Global Guest' do
      let(:current_user) { create :global_guest }
      it_behaves_like :global_user_scope
    end

    context 'As a Global Researcher' do
      let(:current_user) { create :global_researcher }
      it_behaves_like :global_user_scope
    end

    context 'As a Local Administrator' do
      let(:org) { create :organization }
      let(:current_user) { create :admin_of, organization: org }
      it_behaves_like :local_user_scope
    end

    context 'As a Local Teacher' do
      let(:org) { create :organization }
      let(:current_user) { create :teacher_in, organization: org }
      it_behaves_like :local_user_scope
    end

    context 'As a Local Guest' do
      let(:org) { create :organization }
      let(:current_user) { create :guest_in, organization: org }
      it_behaves_like :local_user_scope
    end

    context 'As a Local Researcher' do
      let(:org) { create :organization }
      let(:current_user) { create :researcher_in, organization: org }
      it_behaves_like :local_user_scope
    end

    context 'As a User with roles in multiple organizations' do
      subject(:result) { UserPolicy::Scope.new(current_user, User).resolve }

      let(:org1) { create :organization }
      let(:org2) { create :organization }
      let(:current_user) do
        u = create :admin_of, organization: org1
        u.add_role :teacher, org2
        u
      end

      let(:teachers_in_org1) { create_list :teacher_in, 3, organization: org1 }
      let(:teachers_in_org2) { create_list :teacher_in, 3, organization: org2 }
      let(:teachers_in_org3) { create_list :teacher_in, 3, organization: create(:organization) }

      it 'includes all users from the first organization' do
        expect(result).to include(*teachers_in_org1)
      end

      it 'includes all users from the second organization' do
        expect(result).to include(*teachers_in_org2)
      end

      it 'includes itself' do
        expect(result).to include(current_user)
      end

      it 'does not include users from a different organization' do
        expect(result).not_to include(*teachers_in_org3)
      end
    end
  end
end
