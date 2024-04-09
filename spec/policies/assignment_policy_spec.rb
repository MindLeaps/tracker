require 'rails_helper'
RSpec.describe AssignmentPolicy do
  describe 'permissions' do
    subject { AssignmentPolicy.new current_user, assignment }

    context 'as a Super Administrator' do
      let(:current_user) { create :super_admin }

      context 'on an Assignment Resource' do
        let(:assignment) { Assignment }
        it { is_expected.to permit_action :index }
      end
    end

    context 'as a Global Administrator' do
      let(:current_user) { create :global_admin }

      context 'on an Assignment Resource' do
        let(:assignment) { Assignment }
        it { is_expected.to permit_action :index }
      end
    end

    context 'as a Global Guest' do
      let(:current_user) { create :global_guest }

      context 'on an Assignment Resource' do
        let(:assignment) { Assignment }
        it { is_expected.to permit_action :index }
      end
    end

    context 'as a Global Researcher' do
      let(:current_user) { create :global_researcher }

      context 'on an Assignment Resource' do
        let(:assignment) { Assignment }
        it { is_expected.to permit_action :index }
      end
    end

    context 'as a Local Administrator' do
      let(:org) { create :organization }
      let(:current_user) { create :admin_of, organization: org }

      context 'on an Assignment Resource' do
        let(:assignment) { Assignment }
        it { is_expected.to permit_action :index }
      end
    end

    context 'as a Local Teacher' do
      let(:org) { create :organization }
      let(:current_user) { create :teacher_in, organization: org }

      context 'on an Assignment Resource' do
        let(:assignment) { Assignment }
        it { is_expected.to permit_action :index }
      end
    end

    context 'as a Local Guest' do
      let(:org) { create :organization }
      let(:current_user) { create :guest_in, organization: org }

      context 'on an Assignment Resource' do
        let(:assignment) { Assignment }
        it { is_expected.to permit_action :index }
      end
    end

    context 'as a Local Researcher' do
      let(:org) { create :organization }
      let(:current_user) { create :researcher_in, organization: org }

      context 'on an Assignment Resource' do
        let(:assignment) { Assignment }
        it { is_expected.to permit_action :index }
      end
    end
  end

  describe 'scope' do
    RSpec.shared_examples :global_user_assignment_scope do
      subject(:result) { AssignmentPolicy::Scope.new(current_user, Assignment).resolve }
      let(:org1) { create :organization }
      let(:org2) { create :organization }
      let(:skill1) { create :skill, organization: org1 }
      let(:subject1) { create :subject, organization: org2 }
      let(:assignments_with_skill) { create_list :assignment, 3, skill: skill1 }
      let(:assignments_with_subject) { create_list :assignment, 3, subject: subject1 }

      it 'returns all assignments from the first organization' do
        expect(result).to include(*assignments_with_skill)
      end

      it 'returns all assignments from the second organization' do
        expect(result).to include(*assignments_with_subject)
      end
    end

    RSpec.shared_examples :local_user_assignment_scope do
      subject(:result) { AssignmentPolicy::Scope.new(current_user, Assignment).resolve }
      let(:org1) { create :organization }
      let(:org2) { create :organization }
      let(:skill1) { create :skill, organization: org1 }
      let(:subject1) { create :subject, organization: org2 }
      let(:assignments_with_skill) { create_list :assignment, 3, skill: skill1 }
      let(:assignments_with_subject) { create_list :assignment, 3, subject: subject1 }

      it 'includes assignments that have skills from the first organization' do
        expect(result).to include(*assignments_with_skill)
      end

      it 'does not include assignments that have subjects from the second organization' do
        expect(result).not_to include(*assignments_with_subject)
      end
    end

    context 'As a Super Administrator' do
      let(:current_user) { create :super_admin }
      it_behaves_like :global_user_assignment_scope
    end

    context 'As a Global Administrator' do
      let(:current_user) { create :global_admin }
      it_behaves_like :global_user_assignment_scope
    end

    context 'As a Global Guest' do
      let(:current_user) { create :global_guest }
      it_behaves_like :global_user_assignment_scope
    end

    context 'As a Global Researcher' do
      let(:current_user) { create :global_researcher }
      it_behaves_like :global_user_assignment_scope
    end

    context 'As a Local Administrator' do
      let(:org) { create :organization }
      let(:current_user) { create :admin_of, organization: org1 }
      it_behaves_like :local_user_assignment_scope
    end

    context 'As a Local Teacher' do
      let(:org) { create :organization }
      let(:current_user) { create :teacher_in, organization: org1 }
      it_behaves_like :local_user_assignment_scope
    end

    context 'As a Local Guest' do
      let(:org) { create :organization }
      let(:current_user) { create :guest_in, organization: org1 }
      it_behaves_like :local_user_assignment_scope
    end

    context 'As a Local Researcher' do
      let(:org) { create :organization }
      let(:current_user) { create :researcher_in, organization: org1 }
      it_behaves_like :local_user_assignment_scope
    end

    context 'As a User with roles in multiple organizations' do
      subject(:result) { AssignmentPolicy::Scope.new(current_user, Assignment).resolve }

      let(:org1) { create :organization }
      let(:org2) { create :organization }
      let(:current_user) do
        u = create :admin_of, organization: org1
        u.add_role :teacher, org2
        u
      end

      let(:skill1) { create :skill, organization: org1 }
      let(:subject1) { create :subject, organization: org2 }
      let(:assignments_with_skill) { create_list :assignment, 3, skill: skill1 }
      let(:assignments_with_subject) { create_list :assignment, 3, subject: subject1 }

      it 'includes all assignments from the first organization' do
        expect(result).to include(*assignments_with_skill)
      end

      it 'includes all assignments from the second organization' do
        expect(result).to include(*assignments_with_subject)
      end
    end
  end
end
