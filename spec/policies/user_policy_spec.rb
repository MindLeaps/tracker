require 'rails_helper'

RSpec.describe UserPolicy do
  subject { described_class.new current_user, user }

  context 'as a super administrator' do
    let(:current_user) { create :super_admin }

    context 'on a User resource' do
      let(:user) { User }

      it { is_expected.to permit_action :index }
      it { is_expected.to permit_action :create }
    end

    context 'on another super administrator' do
      let(:user) { create :super_admin }

      it { is_expected.to permit_action :show }
      it { is_expected.to forbid_action :update }
    end

    context 'on an administrator' do
      let(:user) { create :admin }

      it { is_expected.to permit_action :show }
      it { is_expected.to permit_action :update }
    end

    context 'on a normal user' do
      let(:user) { create :user }

      it { is_expected.to permit_action :show }
      it { is_expected.to permit_action :update }
    end

    context 'on self' do
      let(:user) { current_user }

      it { is_expected.to permit_action :show }
      it { is_expected.to permit_action :update }
    end
  end

  context 'as an administrator' do
    let(:current_user) { create :admin }

    context 'on a User resource' do
      let(:user) { User }

      it { is_expected.to permit_action :index }
      it { is_expected.to permit_action :create }
    end

    context 'on a super administrator' do
      let(:user) { create :super_admin }

      it { is_expected.to permit_action :show }
      it { is_expected.to forbid_action :update }
    end

    context 'on another administrator' do
      let(:user) { create :admin }

      it { is_expected.to permit_action :show }
      it { is_expected.to forbid_action :update }
    end

    context 'on a normal user' do
      let(:user) { create :user }

      it { is_expected.to permit_action :show }
      it { is_expected.to permit_action :update }
    end

    context 'on self' do
      let(:user) { current_user }

      it { is_expected.to permit_action :show }
      it { is_expected.to permit_action :update }
    end
  end

  context 'as a regular user' do
    let(:current_user) { create :user }

    context 'on a User resouce' do
      let(:user) { User }

      it { is_expected.to forbid_action :index }
      it { is_expected.to forbid_action :create }
    end

    context 'on a super administrator' do
      let(:user) { create :super_admin }

      it { is_expected.to forbid_action :show }
      it { is_expected.to forbid_action :update }
    end

    context 'on an administrator' do
      let(:user) { create :admin }

      it { is_expected.to forbid_action :show }
      it { is_expected.to forbid_action :update }
    end

    context 'on another normal user' do
      let(:user) { create :user }

      it { is_expected.to forbid_action :show }
      it { is_expected.to forbid_action :update }
    end

    context 'on self' do
      let(:user) { current_user }

      it { is_expected.to permit_action :show }
      it { is_expected.to forbid_action :update }
    end
  end
end
