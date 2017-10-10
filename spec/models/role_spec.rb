# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Role, type: :model do
  let(:org) { create :organization }
  let(:user) { create :user }
  describe 'validations' do
    describe 'correct_role_scope' do
      describe 'super_admin' do
        it 'is valid when set as global role' do
          user.add_role :super_admin
          expect(user.has_role?(:super_admin)).to be true
        end

        it 'is invalid when set as a local role' do
          user.add_role :super_admin, org
          expect(user.has_role?(:super_admin)).to be false
          expect(user.has_role?(:super_admin, org)).to be false
        end
      end

      describe 'global_admin' do
        it 'is valid when set as global role' do
          user.add_role :global_admin
          expect(user.has_role?(:global_admin)).to be true
        end

        it 'is invalid when set as a local role' do
          user.add_role :global_admin, org
          expect(user.has_role?(:global_admin)).to be false
          expect(user.has_role?(:global_admin, org)).to be false
        end
      end

      describe 'admin' do
        it 'is invalid when set as a global role' do
          user.add_role :admin
          expect(user.has_role?(:admin)).to be false
        end

        it 'is valid when set as a local role' do
          user.add_role :admin, org
          expect(user.has_role?(:admin)).to be false
          expect(user.has_role?(:admin, org)).to be true
        end
      end

      describe 'teacher' do
        it 'is invalid when set as a global role' do
          user.add_role :teacher
          expect(user.has_role?(:teacher)).to be false
        end

        it 'is valid when set as a local role' do
          user.add_role :teacher, org
          expect(user.has_role?(:teacher)).to be false
          expect(user.has_role?(:teacher, org)).to be true
        end
      end

      describe 'researcher' do
        it 'is invalid when set as a global role' do
          user.add_role :researcher
          expect(user.has_role?(:researcher)).to be false
        end

        it 'is valid when set as a local role' do
          user.add_role :researcher, org
          expect(user.has_role?(:researcher)).to be false
          expect(user.has_role?(:researcher, org)).to be true
        end
      end
    end
  end
end
