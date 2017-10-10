# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MembershipPolicy do
  describe 'permissions' do
    context 'super administrator' do
      let(:user) { create :super_admin }

      it_behaves_like :it_can_manipulate_all_local_roles
      it_behaves_like :it_can_manipulate_global_role { let(:role) { :global_admin } }
      it_behaves_like :it_can_manipulate_global_role { let(:role) { :global_guest } }
      it_behaves_like :it_can_manipulate_global_role { let(:role) { :global_researcher } }
      it_behaves_like :it_can_add_global_role { let(:role) { :super_admin } }
      it_behaves_like :it_cannot_revoke_global_role { let(:role) { :super_admin } }
    end

    context 'global administrator' do
      let(:user) { create :global_admin }

      it_behaves_like :it_can_manipulate_all_local_roles
      it_behaves_like :it_can_manipulate_global_role { let(:role) { :global_guest } }
      it_behaves_like :it_can_manipulate_global_role { let(:role) { :global_researcher } }
      it_behaves_like :it_can_add_global_role { let(:role) { :global_admin } }
      it_behaves_like :it_cannot_revoke_global_role { let(:role) { :global_admin } }
      it_behaves_like :it_cannot_manipulate_global_role { let(:role) { :super_admin } }
      it_behaves_like :it_cannot_change_global_role do
        let(:role) { :super_admin }
        let(:new_role) { :global_admin }
      end
    end

    context 'global researcher' do
      let(:user) { create :global_researcher }

      it_behaves_like :it_cannot_manipulate_any_roles
    end

    context 'global guest' do
      let(:user) { create :global_guest }

      it_behaves_like :it_cannot_manipulate_any_roles
    end

    context 'local administrator' do
      let(:org) { create :organization }
      let(:user) { create :admin_of, organization: org }

      it_behaves_like :it_cannot_manipulate_any_global_roles
      it_behaves_like :it_can_manipulate_local_role { let(:role) { :guest } }
      it_behaves_like :it_can_manipulate_local_role { let(:role) { :researcher } }
      it_behaves_like :it_can_manipulate_local_role { let(:role) { :teacher } }
      it_behaves_like :it_can_add_local_role { let(:role) { :admin } }
      it_behaves_like :it_cannot_revoke_local_role { let(:role) { :admin } }
    end

    context 'local teacher' do
      let(:org) { create :organization }
      let(:user) { create :teacher_in, organization: org }

      it_behaves_like :it_cannot_manipulate_any_roles
    end

    context 'local researcher' do
      let(:org) { create :organization }
      let(:user) { create :researcher_in, organization: org }

      it_behaves_like :it_cannot_manipulate_any_roles
    end

    context 'local guest' do
      let(:org) { create :organization }
      let(:user) { create :guest_in, organization: org }

      it_behaves_like :it_cannot_manipulate_any_roles
    end
  end
end
