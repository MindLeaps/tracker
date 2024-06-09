# == Schema Information
#
# Table name: roles
#
#  id            :integer          not null, primary key
#  name          :string
#  resource_type :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  resource_id   :integer
#
# Indexes
#
#  index_roles_on_name                                    (name)
#  index_roles_on_name_and_resource_type_and_resource_id  (name,resource_type,resource_id)
#  index_roles_on_resource_type_and_resource_id           (resource_type,resource_id)
#
require 'rails_helper'

RSpec.describe Role, type: :model do
  let(:org) { create :organization }
  let(:user) { create :user }

  describe '#global?' do
    it 'returns true for global roles' do
      user.add_role :super_admin
      expect(user.roles[0].global?).to eq(true)
      user.remove_role :super_admin

      user.add_role :global_admin
      expect(user.roles[0].global?).to eq(true)
      user.remove_role :global_admin

      user.add_role :global_guest
      expect(user.roles[0].global?).to eq(true)
      user.remove_role :global_guest

      user.add_role :global_researcher
      expect(user.roles[0].global?).to eq(true)
      user.remove_role :global_researcher
    end
    it 'returns true for local roles' do
      user.add_role :admin, org
      expect(user.roles.last.global?).to eq(false)
      user.remove_role :admin, org

      user.add_role :teacher, org
      expect(user.roles.last.global?).to eq(false)
      user.remove_role :teacher, org

      user.add_role :researcher, org
      expect(user.roles.last.global?).to eq(false)
      user.remove_role :researcher, org

      user.add_role :guest, org
      expect(user.roles.last.global?).to eq(false)
      user.remove_role :guest, org
    end
  end

  describe 'validations' do
    describe 'correct_role_scope' do
      describe 'super_admin' do
        it 'is valid when set as global role' do
          user.add_role :super_admin
          expect(user.has_role?(:super_admin)).to be true
        end

        it 'is invalid when set as a local role' do
          expect { user.add_role :super_admin, org }.to raise_error ActiveRecord::RecordInvalid
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
          expect { user.add_role :global_admin, org }.to raise_error ActiveRecord::RecordInvalid
          expect(user.has_role?(:global_admin)).to be false
          expect(user.has_role?(:global_admin, org)).to be false
        end
      end

      describe 'admin' do
        it 'is invalid when set as a global role' do
          expect { user.add_role :admin }.to raise_error ActiveRecord::RecordInvalid
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
          expect { user.add_role :teacher }.to raise_error ActiveRecord::RecordInvalid
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
          expect { user.add_role :researcher }.to raise_error ActiveRecord::RecordInvalid
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
