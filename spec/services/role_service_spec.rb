# frozen_string_literal: true

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
end
