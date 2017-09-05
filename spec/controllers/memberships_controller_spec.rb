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
      before { put :update, params: { user_id: user.id, id: org.id, role: :admin } }

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
        put :update, params: { user_id: user.id, id: org2.id, role: :teacher }

        expect(user.has_role?(:teacher, org2)).to be true
      end
    end

    context 'tries to give user an invalid role' do
      before { put :update, params: { user_id: user.id, id: org.id, role: :nonrole } }

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
end
