# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MembershipsController, type: :controller do
  let(:super_admin) { create :super_admin }

  before :each do
    sign_in super_admin
  end

  describe '#update' do
    let(:org) { create :organization }
    let(:org2) { create :organization }
    let(:user) { create :teacher_in, organization: org }

    context 'promotes the user, from teacher to admin, of an organization' do
      before { put :update, params: { user_id: user.id, id: org.id, membership: { role: :admin } } }

      it { should redirect_to user }

      it 'removes the user\'s teacher role' do
        expect(user.has_role?(:teacher, org)).to be false
      end

      it 'grants the user an admin role' do
        expect(user.has_role?(:admin, org)).to be true
      end
    end

    context 'giver the user a role in a new organization' do
      it 'grants user a teacher role' do
        put :update, params: { user_id: user.id, id: org2.id, membership: { role: :teacher } }

        expect(user.has_role?(:teacher, org2)).to be true
      end
    end

    context 'tries to give user an invalid role' do
      before { put :update, params: { user_id: user.id, id: org.id, membership: { role: :nonrole } } }

      it { should respond_with :bad_request }

      it { should render_template 'users/show' }
    end
  end

  describe '#destroy' do
    context 'revoke a role, in organization, from a user' do
      let(:org) { create :organization }
      let(:user) { create :teacher_in, organization: org }
      before { delete :destroy, params: { user_id: user.id, id: org.id } }

      it { should redirect_to user }

      it 'revokes the teacher role in organization' do
        expect(user.has_role?(:teacher, org)).to be false
      end
    end
  end

  describe '#update_global_role' do
    context 'grants a global guest role to the user' do
      let(:user) { create :user }
      before { put :update_global_role, params: { user_id: user.id, role: :global_guest } }

      it { should redirect_to user }

      it 'grants the user a global guest role' do
        expect(user.has_role?(:global_guest)).to be true
      end
    end

    context 'changes a users global role from global guest to global admin' do
      let(:user) { create :global_admin }
      before { put :update_global_role, params: { user_id: user.id, role: :global_admin } }

      it { should redirect_to user }

      it 'grants the user a global admin role' do
        expect(user.has_role?(:global_admin)).to be true
      end

      it 'removes the old global guest role' do
        expect(user.has_role?(:global_guest)).to be false
      end
    end

    context 'tries to grant an invalid role to the user' do
      let(:user) { create :user }
      before { put :update_global_role, params: { user_id: user.id, role: :nonsense_role } }

      it { should respond_with :bad_request }

      it { should render_template :show }

      it 'doesnt grant any role to the user' do
        expect(user.roles.length).to eq 0
      end
    end
  end

  describe '#revoke_global_role' do
    context 'revoke a global guest role from a user' do
      let(:user) { create :global_guest }
      before { delete :revoke_global_role, params: { user_id: user.id } }

      it { should redirect_to user }

      it 'revoke the role' do
        expect(user.has_role?(:global_guest)).to be false
      end
    end
  end
end
