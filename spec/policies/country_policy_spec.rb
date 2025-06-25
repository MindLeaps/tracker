require 'rails_helper'

RSpec.describe CountryPolicy do
  describe 'permissions' do
    subject { CountryPolicy.new current_user, country }

    context 'as a Super Administrator' do
      let(:current_user) { create :super_admin }

      context 'on a Country Resource' do
        let(:country) { Country }

        it { is_expected.to permit_action :index }
        it { is_expected.to permit_action :create }
      end

      context 'on any existing country' do
        let(:country) { create :country }

        it { is_expected.to permit_action :show }
        it { is_expected.to permit_action :destroy }
        it { is_expected.to permit_action :edit }
        it { is_expected.to permit_action :update }
      end
    end

    context 'as a Global Administrator' do
      let(:current_user) { create :global_admin }

      context 'on a Country Resource' do
        let(:country) { Country }

        it { is_expected.to permit_action :index }
        it { is_expected.to permit_action :create }
      end

      context 'on any existing country' do
        let(:country) { create :country }

        it { is_expected.to permit_action :show }
        it { is_expected.to permit_action :destroy }
        it { is_expected.to permit_action :edit }
        it { is_expected.to permit_action :update }
      end
    end

    context 'as a Global Guest' do
      let(:current_user) { create :global_guest }

      context 'on a Country Resource' do
        let(:country) { Country }

        it { is_expected.to permit_action :index }
        it { is_expected.not_to permit_action :create }
      end

      context 'on any existing country' do
        let(:country) { create :country }

        it { is_expected.to permit_action :show }
        it { is_expected.not_to permit_action :destroy }
        it { is_expected.not_to permit_action :edit }
        it { is_expected.not_to permit_action :update }
      end
    end

    context 'as a Global Researcher' do
      let(:current_user) { create :global_researcher }

      context 'on a Country Resource' do
        let(:country) { Country }

        it { is_expected.to permit_action :index }
        it { is_expected.not_to permit_action :create }
      end

      context 'on any existing country' do
        let(:country) { create :country }

        it { is_expected.to permit_action :show }
        it { is_expected.not_to permit_action :destroy }
        it { is_expected.not_to permit_action :edit }
        it { is_expected.not_to permit_action :update }
      end
    end

    context 'as a Local Administrator' do
      let(:org) { create :organization }
      let(:current_user) { create :admin_of, organization: org }

      context 'on a Country Resource' do
        let(:country) { Country }

        it { is_expected.to permit_action :index }
        it { is_expected.to permit_action :create }
      end

      context 'on any existing country' do
        let(:country) { create :country }

        it { is_expected.to permit_action :show }
        it { is_expected.to permit_action :destroy }
        it { is_expected.to permit_action :edit }
        it { is_expected.to permit_action :update }
      end
    end

    context 'as a Local Teacher' do
      let(:org) { create :organization }
      let(:current_user) { create :teacher_in, organization: org }

      context 'on a Country Resource' do
        let(:country) { Country }

        it { is_expected.to permit_action :index }
        it { is_expected.not_to permit_action :create }
      end

      context 'on any existing country' do
        let(:country) { create :country }

        it { is_expected.to permit_action :show }
        it { is_expected.not_to permit_action :destroy }
        it { is_expected.not_to permit_action :edit }
        it { is_expected.not_to permit_action :update }
      end
    end

    context 'as a Local Guest' do
      let(:org) { create :organization }
      let(:current_user) { create :guest_in, organization: org }

      context 'on a Country Resource' do
        let(:country) { Country }

        it { is_expected.to permit_action :index }
        it { is_expected.not_to permit_action :create }
      end

      context 'on any existing country' do
        let(:country) { create :country }

        it { is_expected.to permit_action :show }
        it { is_expected.not_to permit_action :destroy }
        it { is_expected.not_to permit_action :edit }
        it { is_expected.not_to permit_action :update }
      end
    end

    context 'as a Local Researcher' do
      let(:org) { create :organization }
      let(:current_user) { create :researcher_in, organization: org }

      context 'on a Country Resource' do
        let(:country) { Country }

        it { is_expected.to permit_action :index }
        it { is_expected.not_to permit_action :create }
      end

      context 'on any existing country' do
        let(:country) { create :country }

        it { is_expected.to permit_action :show }
        it { is_expected.not_to permit_action :destroy }
        it { is_expected.not_to permit_action :edit }
        it { is_expected.not_to permit_action :update }
      end
    end
  end

  describe 'scope' do
    describe 'resolve' do
      let(:org1) { create :organization }
      let(:org2) { create :organization }
      let(:countries) { create_list :country, 3 }

      subject(:result) { CountryPolicy::Scope.new(current_user, Country).resolve }

      context 'user is a super administrator' do
        let(:current_user) { create :super_admin }

        it 'includes all countries' do
          expect(result).to eq countries
        end
      end

      context 'user is an administrator of one organization' do
        let(:current_user) { create :admin_of, organization: org1 }

        it 'includes all countries' do
          expect(result).to eq countries
        end
      end

      context 'user is a teacher of one organization' do
        let(:current_user) { create :teacher_in, organization: org2 }

        it 'includes all countries' do
          expect(result).to eq countries
        end
      end
    end
  end
end
