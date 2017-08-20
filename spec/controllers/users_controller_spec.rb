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

  describe '#update' do
    let(:org) { create :organization }
    let(:org2) { create :organization }
    let(:user) { create :teacher_in, organization: org }

    context 'promotes the user, from teacher to admin, of an organization' do
      before { put :update, params: { id: user.id, user: { roles: { :"#{org.id}" => :admin } } } }

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
        put :update, params: { id: user.id, user: { roles: { :"#{org2.id}" => :teacher } } }

        expect(user.has_role?(:teacher, org2)).to be true
      end
    end

    context 'tries to give user an invalid role' do
      before { put :update, params: { id: user.id, user: { roles: { :"#{org.id}" => :nonrole } } } }

      it { should respond_with :bad_request }

      it { should render_template :show }
    end
  end
end
