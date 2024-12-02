require 'rails_helper'

RSpec.describe EnrollmentPolicy do
  describe 'permissions' do
    subject { EnrollmentPolicy.new current_user, resource }
    let(:org) { create :organization }
    let(:outside_org)  { create :organization }

    context 'as a super administrator' do
      let(:current_user) { create :super_admin }

      context 'on an Enrollment resource' do
        let(:resource) { Enrollment }

        it { is_expected.to permit_action :index }
        it { is_expected.to permit_action :show }
      end
    end

    context 'as a local teacher' do
      let(:current_user) { create :teacher_in, organization: org }

      context 'on an Enrollment resource' do
        let(:resource) { Enrollment }

        it { is_expected.to permit_action :index }
        it { is_expected.to permit_action :show }
      end

      context 'on an enrollment in user\'s own organization' do
        let(:resource) { create :enrollment, group: create(:group, chapter: create(:chapter, organization: org)) }

        it { is_expected.to permit_action :index }
        it { is_expected.to permit_action :show }
      end

      context 'on an enrollment outside of users\'s own organization' do
        let(:resource) { create :enrollment, group: create(:group, chapter: create(:chapter, organization: outside_org)) }

        it { is_expected.not_to permit_action :index }
        it { is_expected.not_to permit_action :show }
      end

      context 'on a newly created enrollment in user\'s own organization' do
        let(:resource) { build :enrollment, group: create(:group, chapter: create(:chapter, organization: org)) }

        it { is_expected.to permit_action :index }
        it { is_expected.to permit_action :show }
      end

      context 'on a newly created enrollment in a different organization' do
        let(:resource) { build :enrollment, group: create(:group, chapter: create(:chapter, organization: outside_org)) }

        it { is_expected.not_to permit_action :index }
        it { is_expected.not_to permit_action :show }
      end
    end

    context 'as a local researcher' do
      let(:current_user) { create :researcher_in, organization: org }

      context 'on an Enrollment resource' do
        let(:resource) { Enrollment }

        it { is_expected.to permit_action :index }
        it { is_expected.to permit_action :show }
      end

      context 'on an enrollment in user\'s own organization' do
        let(:resource) { create :enrollment, group: create(:group, chapter: create(:chapter, organization: org)) }

        it { is_expected.to permit_action :index }
        it { is_expected.to permit_action :show }
      end

      context 'on an enrollment outside of users\'s own organization' do
        let(:resource) { create :enrollment, group: create(:group, chapter: create(:chapter, organization: outside_org)) }

        it { is_expected.not_to permit_action :index }
        it { is_expected.not_to permit_action :show }
      end
    end
  end

  describe 'scope' do
    subject(:result) { EnrollmentPolicy::Scope.new(current_user, Enrollment).resolve }
    let(:org1) { create :organization }
    let(:org2) { create :organization }
    let(:enrollment1) { create :enrollment, group: create(:group, chapter: create(:chapter, organization: org1)) }
    let(:enrollment2) { create :enrollment, group: create(:group, chapter: create(:chapter, organization: org1)) }
    let(:enrollment3) { create :enrollment, group: create(:group, chapter: create(:chapter, organization: org2)) }

    context 'logged in as a super administrator' do
      let(:current_user) { create :super_admin }

      it 'includes all enrollments' do
        expect(result).to include enrollment1, enrollment2, enrollment3
      end
    end

    context 'logged in as an admin of a specific organization' do
      let(:current_user) { create :admin_of, organization: org1 }

      it 'includes enrollments from the user\'s organization' do
        expect(result).to include enrollment1, enrollment2
      end

      it 'excludes enrollments from other organizations' do
        expect(result).to_not include enrollment3
      end
    end

    context 'as a global guest' do
      let(:current_user) { create :global_guest }

      it 'includes all enrollments' do
        expect(result).to include enrollment1, enrollment2, enrollment3
      end
    end
  end
end
