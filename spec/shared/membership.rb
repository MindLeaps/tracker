# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples :it_can_manipulate_all_local_roles do
  it_behaves_like :it_can_manipulate_all_local_roles_in do
    let(:org) { create :organization }
  end
end

RSpec.shared_examples :it_cannot_manipulate_any_roles do
  it_behaves_like :it_cannot_manipulate_any_global_roles
  it_behaves_like :it_cannot_manipulate_any_local_roles_in do
    let(:org) { create :organization }
  end
end

RSpec.shared_examples :it_cannot_manipulate_any_global_roles do
  Role::GLOBAL_ROLES.each_key do |r|
    it_behaves_like(:it_cannot_manipulate_global_role) { let(:role) { r } }
  end
end

RSpec.shared_examples :it_can_manipulate_all_local_roles_in do
  it_behaves_like :it_can_manipulate_admin_roles_in
  it_behaves_like :it_can_manipulate_non_admin_roles_in
end

RSpec.shared_examples :it_cannot_manipulate_any_local_roles_in do
  Role::LOCAL_ROLES.each_key do |r|
    it_behaves_like(:it_cannot_manipulate_local_role) { let(:role) { r } }
  end
end

RSpec.shared_examples :it_can_manipulate_admin_roles_in do
  it_behaves_like(:it_can_manipulate_local_role) { let(:role) { :admin } }
end

RSpec.shared_examples :it_cannot_manipulate_admin_roles_in do
  it_behaves_like(:it_cannot_manipulate_local_role) { let(:role) { :admin } }
end

RSpec.shared_examples :it_can_manipulate_non_admin_roles_in do
  it_behaves_like(:it_can_manipulate_local_role) { let(:role) { :guest } }
  it_behaves_like(:it_can_manipulate_local_role) { let(:role) { :researcher } }
  it_behaves_like(:it_can_manipulate_local_role) { let(:role) { :teacher } }
end

RSpec.shared_examples :it_cannot_manipulate_non_admin_roles_in do
  it_behaves_like(:it_cannot_manipulate_local_role) { let(:role) { :guest } }
  it_behaves_like(:it_cannot_manipulate_local_role) { let(:role) { :researcher } }
  it_behaves_like(:it_cannot_manipulate_local_role) { let(:role) { :teacher } }
end

RSpec.shared_examples :it_can_manipulate_local_role do
  it_behaves_like :it_can_add_local_role
  it_behaves_like :it_can_revoke_local_role
end

RSpec.shared_examples :it_cannot_manipulate_local_role do
  it_behaves_like :it_cannot_add_local_role
  it_behaves_like :it_cannot_revoke_local_role
  it_behaves_like :it_cannot_change_local_role
end

RSpec.shared_examples :it_can_add_local_role do
  subject { MembershipPolicy.new user, membership }

  context :grant_local_role_organization do
    let(:other_user) { create :user }
    let(:membership) { Membership.new user: other_user, role: role, org: org }
    it { is_expected.to permit_action :update }
  end
end

RSpec.shared_examples :it_cannot_add_local_role do
  subject { MembershipPolicy.new user, membership }

  context :grant_local_role_organization do
    let(:other_user) { create :user }
    let(:membership) { Membership.new user: other_user, role: role, org: org }
    it { is_expected.to forbid_action :update }
  end
end

RSpec.shared_examples :it_can_revoke_local_role do
  subject { MembershipPolicy.new user, membership }

  context :revoke_user_from_organization do
    let(:other_user) { create :user_with_role, role: role, organization: org }
    let(:membership) { Membership.new user: other_user, org: org }
    it { is_expected.to permit_action :destroy }
  end
end

RSpec.shared_examples :it_cannot_revoke_local_role do
  subject { MembershipPolicy.new user, membership }

  context :revoke_user_from_organization do
    let(:other_user) { create :user_with_role, role: role, organization: org }
    let(:membership) { Membership.new user: other_user, org: org }
    it { is_expected.to forbid_action :destroy }
  end
end

RSpec.shared_examples :it_cannot_change_local_role do
  subject { MembershipPolicy.new user, membership }

  context :change_local_role_for_user do
    let(:other_user) { create :user_with_role, role: role, organization: org }
    let(:membership) { Membership.new user: other_user, role: :guest, org: org }
    it { is_expected.to forbid_action :update }
  end
end

RSpec.shared_examples :it_can_manipulate_global_role do
  it_behaves_like :it_can_add_global_role
  it_behaves_like :it_can_revoke_global_role
end

RSpec.shared_examples :it_cannot_manipulate_global_role do
  it_behaves_like :it_cannot_add_global_role
  it_behaves_like :it_cannot_revoke_global_role
  it_behaves_like :it_cannot_change_global_role
end

RSpec.shared_examples :it_can_add_global_role do
  subject { MembershipPolicy.new user, membership }

  context :grant_global_role_to_user do
    let(:other_user) { create :user }
    let(:membership) { Membership.new user: other_user, role: role }
    it { is_expected.to permit_action :update_global_role }
  end
end

RSpec.shared_examples :it_can_revoke_global_role do
  subject { MembershipPolicy.new user, membership }

  context :grant_global_role_to_user do
    let(:other_user) { create :user_with_global_role, role: role }
    let(:membership) { Membership.new user: other_user }
    it { is_expected.to permit_action :revoke_global_role }
  end
end

RSpec.shared_examples :it_cannot_add_global_role do
  subject { MembershipPolicy.new user, membership }

  context :grant_global_role_to_user do
    let(:other_user) { create :user }
    let(:membership) { Membership.new user: other_user, role: role }
    it { is_expected.to forbid_action :update_global_role }
  end
end

RSpec.shared_examples :it_cannot_revoke_global_role do
  subject { MembershipPolicy.new user, membership }

  context :revoke_global_role_from_user do
    let(:other_user) { create :user_with_global_role, role: role }
    let(:membership) { Membership.new user: other_user }
    it { is_expected.to forbid_action :revoke_global_role }
  end
end

RSpec.shared_examples :it_cannot_change_global_role do
  subject { MembershipPolicy.new user, membership }

  context :revoke_global_role_from_user do
    let(:other_user) { create :user_with_global_role, role: role }
    let(:membership) { Membership.new user: other_user, role: :global_guest }
    it { is_expected.to forbid_action :update_global_role }
  end
end
