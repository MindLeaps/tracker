require 'rails_helper'

RSpec.describe RoleService do
  describe '#update_local_role' do
    let(:org) { create :organization }
    let(:org2) { create :organization }
    let(:user) { create :teacher_in, organization: org }

    context 'grants a new role in the organization' do
      it 'grants a role in the specified organization' do
        RoleService.update_local_role user, :teacher, org

        expect(user.has_role?(:teacher, org)).to eq true
      end

      it 'grants roles in multiple organizations' do
        RoleService.update_local_role user, :teacher, org
        RoleService.update_local_role user, :admin, org2

        expect(user.has_role?(:teacher, org)).to eq true
        expect(user.has_role?(:admin, org2)).to eq true
      end
    end

    context 'updates the user\'s role from teacher to admin of an organization' do
      it 'removes the user\'s old teacher role' do
        RoleService.update_local_role user, :admin, org
        expect(user.has_role?(:teacher, org)).to be false
      end

      it 'grants the user a new admin role ' do
        RoleService.update_local_role user, :admin, org
        expect(user.has_role?(:admin, org)).to be true
      end

      it 'returns true' do
        expect(RoleService.update_local_role(user, :admin, org)).to be true
      end
    end

    context 'tries to perform an invalid role update' do
      it 'does not remove the old teacher role' do
        RoleService.update_local_role user, :nonexist, org
        expect(user.has_role?(:teacher, org)).to be true
      end

      it 'does not grant a new nonexist role' do
        RoleService.update_local_role user, :nonexist, org
        expect(user.has_role?(:nonexist, org)).to be false
      end

      it 'returns false' do
        expect(RoleService.update_local_role(user, :nonexist, org)).to be false
      end
    end
  end

  describe '#update_global_role' do
    context 'User does not have any roles' do
      let(:user) { create :user }

      it 'grants the user a global administrator role and returns true' do
        expect(RoleService.update_global_role(user, :global_admin)).to be true
        expect(user.has_role?(:global_admin)).to be true
      end

      it 'does not grant an invalid global role and returns false' do
        expect(RoleService.update_global_role(user, :nonexist)).to be false
        expect(user.has_role?(:nonexist)).to be false
      end
    end

    context 'User already has a global guest role' do
      let(:user) { create :global_guest }

      it 'grants the user a global administrator role and returns true' do
        expect(RoleService.update_global_role(user, :global_admin)).to be true
        expect(user.has_role?(:global_admin)).to be true
      end

      it 'removes the existing global guest role' do
        RoleService.update_global_role user, :global_admin
        expect(user.has_role?(:global_guest)).to be false
      end
    end
  end

  describe '#revoke_local_role' do
    context 'user has a local teacher role' do
      let(:org) { create :organization }
      let(:user) { create :teacher_in, organization: org }

      it 'revokes a teacher role in organization from user' do
        RoleService.revoke_local_role user, org
        expect(user.has_role?(:teacher, org)).to be false
      end
    end

    context 'user has a local teacher role, and an admin role in another organization' do
      let(:org) { create :organization }
      let(:org2) { create :organization }
      let(:user) { create :teacher_in, organization: org }
      before :each do
        user.add_role :admin, org2
        RoleService.revoke_local_role user, org
      end

      it 'revokes a teacher role in organization from user' do
        expect(user.has_role?(:teacher, org)).to be false
      end

      it 'does not revoke an admin role' do
        expect(user.has_role?(:admin, org2)).to be true
      end
    end
  end

  describe '#revoke_global_role' do
    context 'user has a global guest role' do
      let(:user) { create :global_guest }

      it 'revokes the role from a user' do
        RoleService.revoke_global_role user
        expect(user.has_role?(:global_guest)).to be false
      end
    end
  end
end
