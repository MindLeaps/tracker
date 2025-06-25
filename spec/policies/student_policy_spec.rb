require 'rails_helper'

RSpec.describe StudentPolicy do
  describe 'permissions' do
    subject { StudentPolicy.new current_user, resource }
    let(:org) { create :organization }
    let(:org2)  { create :organization }

    context 'as a super administrator' do
      let(:current_user) { create :super_admin }

      context 'on a Student resource' do
        let(:resource) { Student }

        it { is_expected.to permit_action :index }
        it { is_expected.to permit_action :new }
      end

      context 'on any existing student' do
        let(:resource) { create :student }

        it { is_expected.to permit_action :performance }
        it { is_expected.to permit_action :details }
        it { is_expected.to permit_action :update }
        it { is_expected.to permit_action :destroy }
        it { is_expected.to permit_action :undelete }
      end

      context 'on a newly created student' do
        let(:resource) { build :student }

        it { is_expected.to permit_action :create }
      end
    end

    context 'as a local teacher' do
      let(:current_user) { create :teacher_in, organization: org }

      context 'on a Student resource' do
        let(:resource) { Student }

        it { is_expected.to permit_action :index }
        it { is_expected.to permit_action :new }
      end

      context 'on a student in user\'s own organization' do
        let(:resource) { create :enrolled_student, organization: org, groups: [create(:group, chapter: create(:chapter, organization: org))] }

        it { is_expected.to permit_action :performance }
        it { is_expected.to permit_action :details }
        it { is_expected.to permit_action :update }
        it { is_expected.to permit_action :destroy }
        it { is_expected.to permit_action :undelete }
      end

      context 'on a student outside of users\'s own organization' do
        let(:resource) { create :enrolled_student, organization: org2, groups: [create(:group, chapter: create(:chapter, organization: org2))] }

        it { is_expected.not_to permit_action :performance }
        it { is_expected.not_to permit_action :details }
        it { is_expected.not_to permit_action :update }
        it { is_expected.not_to permit_action :destroy }
        it { is_expected.not_to permit_action :undelete }
      end

      context 'on a newly created student in user\'s own organization' do
        let(:resource) { build :enrolled_student, organization: org, groups: [create(:group, chapter: create(:chapter, organization: org))] }

        it { is_expected.to permit_action :create }
      end

      context 'on a newly created student in a different organization' do
        let(:resource) { build :enrolled_student, organization: org2, groups: [create(:group, chapter: create(:chapter, organization: org2))] }

        it { is_expected.not_to permit_action :create }
      end
    end

    context 'as a local researcher' do
      let(:current_user) { create :researcher_in, organization: org }

      context 'on a Student resource' do
        let(:resource) { Student }

        it { is_expected.to permit_action :index }
        it { is_expected.not_to permit_action :new }
      end

      context 'on a student in user\'s own organization' do
        let(:resource) { create :enrolled_student, organization: org, groups: [create(:group, chapter: create(:chapter, organization: org))] }

        it { is_expected.to permit_action :performance }
        it { is_expected.to permit_action :details }
        it { is_expected.not_to permit_action :update }
        it { is_expected.not_to permit_action :destroy }
        it { is_expected.not_to permit_action :undelete }
      end

      context 'on a student outside of users\'s own organization' do
        let(:resource) { create :enrolled_student, organization: org2, groups: [create(:group, chapter: create(:chapter, organization: org2))] }

        it { is_expected.not_to permit_action :performance }
        it { is_expected.not_to permit_action :details }
        it { is_expected.not_to permit_action :update }
        it { is_expected.not_to permit_action :destroy }
        it { is_expected.not_to permit_action :undelete }
      end

      context 'on a newly created student in user\'s own organization' do
        let(:resource) { build :enrolled_student, organization: org, groups: [create(:group, chapter: create(:chapter, organization: org))] }

        it { is_expected.not_to permit_action :create }
      end
    end
  end

  describe 'scope' do
    subject(:result) { StudentPolicy::Scope.new(current_user, Student).resolve }
    let(:org1) { create :organization }
    let(:org2) { create :organization }
    let(:student1) { create :enrolled_student, organization: org1, groups: [create(:group, chapter: create(:chapter, organization: org1))] }
    let(:student2) { create :enrolled_student, organization: org1, groups: [create(:group, chapter: create(:chapter, organization: org1))] }
    let(:student3) { create :enrolled_student, organization: org2, groups: [create(:group, chapter: create(:chapter, organization: org2))] }

    context 'logged in as a super administrator' do
      let(:current_user) { create :super_admin }

      it 'includes all students' do
        expect(result).to include student1, student2, student3
      end
    end

    context 'logged in as an admin of a specific organization' do
      let(:current_user) { create :admin_of, organization: org1 }

      it 'includes students from the user\'s organization' do
        expect(result).to include student1, student2
      end

      it 'excludes students in other organizations' do
        expect(result).to_not include student3
      end

      it 'excludes students in other organizations that have admin users' do
        create :admin_of, organization: org2

        expect(result).to_not include student3
      end
    end

    context 'as a global guest' do
      let(:current_user) { create :global_guest }

      it 'includes all students' do
        expect(result).to include student1, student2, student3
      end
    end
  end
end
