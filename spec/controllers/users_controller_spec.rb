# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:super_admin) { create :super_admin }

  before :each do
    sign_in super_admin
  end

  describe '#index' do
    it 'lists all existing users' do
      user1 = create :user, name: 'user one'
      user2 = create :user, name: 'user two'

      get :index
      expect(response).to be_success

      expect(assigns(:users)).to include user1
      expect(assigns(:users)).to include user2
    end
  end

  describe '#update_local_role' do
    let(:org) { create :organization }
    let(:org2) { create :organization }
    let(:user) { create :teacher_in, organization: org }

    context 'promotes the user, from teacher to admin, of an organization' do
      before { put :update_local_role, params: { id: user.id, user: { roles: { :"#{org.id}" => :admin } } } }

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
        put :update_local_role, params: { id: user.id, user: { roles: { :"#{org2.id}" => :teacher } } }

        expect(user.has_role?(:teacher, org2)).to be true
      end
    end

    context 'tries to give user an invalid role' do
      before { put :update_local_role, params: { id: user.id, user: { roles: { :"#{org.id}" => :nonrole } } } }

      it { should respond_with :bad_request }

      it { should render_template :show }
    end
  end

  describe '#update_global_role' do
    context 'grants a global guest role to the user' do
      let(:user) { create :user }
      before { put :update_global_role, params: { id: user.id, user: { role: :global_guest } } }

      it { should redirect_to user }

      it 'grants the user a global guest role' do
        expect(user.has_role?(:global_guest)).to be true
      end
    end

    context 'changes a users global role from global guest to global admin' do
      let(:user) { create :global_admin }
      before { put :update_global_role, params: { id: user.id, user: { role: :global_admin } } }

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
      before { put :update_global_role, params: { id: user.id, user: { role: :nonsense_role } } }

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
      before { delete :revoke_global_role, params: { id: user.id } }

      it { should redirect_to user }

      it 'revoke the role' do
        expect(user.has_role?(:global_guest)).to be false
      end
    end
  end
end
