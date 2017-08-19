# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RolePolicy do
  describe 'scope' do
    subject { RolePolicy::Scope.new(current_user, Role.all).resolve }

    before :each do
      @orgs = create_list :organization, 3
      @user1 = create :admin_of, organization: @orgs.first
      @user2 = create :teacher_in, organization: @orgs.second
      @user3 = create :teacher_in, organization: @orgs.third
    end

    context 'as a global super admin' do
      let(:current_user) { create :super_admin }

      it { is_expected.to include(*@user1.roles) }
      it { is_expected.to include(*@user2.roles) }
      it { is_expected.to include(*@user3.roles) }
      it { is_expected.to include(*current_user.roles) }
    end

    context 'as a member of an organization' do
      let(:current_user) { create :teacher_in, organization: @orgs.first }

      it { is_expected.to include(*current_user.roles) }
      it { is_expected.to include(*@user1.roles) }
      it { is_expected.not_to include(*@user2.roles) }
      it { is_expected.not_to include(*@user3.roles) }
    end
  end
end
