# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrganizationPolicy do
  subject { described_class.new user, organization }

  context 'as a super administrator' do
    let(:user) { create :super_admin }

    context 'on an Organization resource' do
      let(:organization) { Organization }

      it { is_expected.to permit_action :index }
      it { is_expected.to permit_action :create }
    end

    context 'on a single organization' do
      let(:organization) { create :organization }

      it { is_expected.to permit_action :show }
      it { is_expected.to permit_action :update }
    end
  end

  context 'as an administrator' do
    let(:user) { create :admin }

    context 'on an Organization resource' do
      let(:organization) { Organization }

      it { is_expected.to permit_action :index }
      it { is_expected.to permit_action :create }
    end

    context 'on a single organization' do
      let(:organization) { create :organization }

      it { is_expected.to permit_action :show }
      it { is_expected.to permit_action :update }
    end
  end

  context 'as a regular user' do
    let(:user) { create :user }

    context 'on an Organization resource' do
      let(:organization) { Organization }

      it { is_expected.to forbid_action :index }
      it { is_expected.to forbid_action :create }
    end

    context 'on a single organization' do
      let(:organization) { create :organization }

      it { is_expected.to forbid_action :show }
      it { is_expected.to forbid_action :update }
    end
  end
end
