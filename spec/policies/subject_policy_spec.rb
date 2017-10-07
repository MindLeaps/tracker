# frozen_string_literal: true

require 'rails_helper'
RSpec.describe SubjectPolicy do
  describe 'permissions' do
    subject { SubjectPolicy.new current_user, tested_subject }

    context 'as a Super Administrator' do
      let(:current_user) { create :super_admin }

      context 'on a Subject Resource' do
        let(:tested_subject) { Subject }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing subject' do
        let(:tested_subject) { create :subject }
        it { is_expected.to permit_action :show }
        it { is_expected.to permit_edit_and_update_actions }
      end

      context 'on a new subject' do
        let(:tested_subject) { build :subject }
        it { is_expected.to permit_action :create }
      end
    end

    context 'as a Global Administrator' do
      let(:current_user) { create :global_admin }

      context 'on a Subject Resource' do
        let(:tested_subject) { Subject }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing subject' do
        let(:tested_subject) { create :subject }
        it { is_expected.to permit_action :show }
        it { is_expected.to permit_edit_and_update_actions }
      end

      context 'on a new subject' do
        let(:tested_subject) { build :subject }
        it { is_expected.to permit_action :create }
      end
    end

    context 'as a Global Guest' do
      let(:current_user) { create :global_guest }

      context 'on a Subject Resource' do
        let(:tested_subject) { Subject }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing subject' do
        let(:tested_subject) { create :subject }
        it { is_expected.to permit_action :show }
        it { is_expected.to forbid_edit_and_update_actions }
      end

      context 'on a new subject' do
        let(:tested_subject) { build :subject }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Global Researcher' do
      let(:current_user) { create :global_researcher }

      context 'on a Subject Resource' do
        let(:tested_subject) { Subject }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing subject' do
        let(:tested_subject) { create :subject }
        it { is_expected.to permit_action :show }
        it { is_expected.to forbid_edit_and_update_actions }
      end

      context 'on a new subject' do
        let(:tested_subject) { build :subject }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Local Administrator' do
      let(:org) { create :organization }
      let(:current_user) { create :admin_of, organization: org }

      context 'on a Subject Resource' do
        let(:tested_subject) { Subject }
        it { is_expected.to permit_action :index }
      end

      context 'on a subject inside own\'s organization' do
        let(:tested_subject) { create :subject, organization: org }
        it { is_expected.to permit_action :show }
        it { is_expected.to permit_edit_and_update_actions }
      end

      context 'on a subject outside of own\'s organization' do
        let(:tested_subject) { create :subject, organization: create(:organization) }
        it { is_expected.to forbid_action :show }
        it { is_expected.to forbid_edit_and_update_actions }
      end

      context 'on a new subject in own organization' do
        let(:tested_subject) { build :subject, organization: org }
        it { is_expected.to permit_action :create }
      end

      context 'on a new subject outside of own organization' do
        let(:tested_subject) { build :subject, organization: create(:organization) }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Local Teacher' do
      let(:org) { create :organization }
      let(:current_user) { create :teacher_in, organization: org }

      context 'on a Subject Resource' do
        let(:tested_subject) { Subject }
        it { is_expected.to permit_action :index }
      end

      context 'on a subject inside own\'s organization' do
        let(:tested_subject) { create :subject, organization: org }
        it { is_expected.to permit_action :show }
        it { is_expected.to forbid_edit_and_update_actions }
      end

      context 'on a subject outside of own\'s organization' do
        let(:tested_subject) { create :subject, organization: create(:organization) }
        it { is_expected.to forbid_action :show }
        it { is_expected.to forbid_edit_and_update_actions }
      end

      context 'on a new subject in own organization' do
        let(:tested_subject) { build :subject, organization: org }
        it { is_expected.to forbid_action :create }
      end

      context 'on a new subject outside of own organization' do
        let(:tested_subject) { build :subject, organization: create(:organization) }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Local Guest' do
      let(:org) { create :organization }
      let(:current_user) { create :guest_in, organization: org }

      context 'on a Subject Resource' do
        let(:tested_subject) { Subject }
        it { is_expected.to permit_action :index }
      end

      context 'on a subject inside own\'s organization' do
        let(:tested_subject) { create :subject, organization: org }
        it { is_expected.to permit_action :show }
        it { is_expected.to forbid_edit_and_update_actions }
      end

      context 'on a subject outside of own\'s organization' do
        let(:tested_subject) { create :subject, organization: create(:organization) }
        it { is_expected.to forbid_action :show }
        it { is_expected.to forbid_edit_and_update_actions }
      end

      context 'on a new subject in own organization' do
        let(:tested_subject) { build :subject, organization: org }
        it { is_expected.to forbid_action :create }
      end

      context 'on a new subject outside of own organization' do
        let(:tested_subject) { build :subject, organization: create(:organization) }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Local Researcher' do
      let(:org) { create :organization }
      let(:current_user) { create :researcher_in, organization: org }

      context 'on a Subject Resource' do
        let(:tested_subject) { Subject }
        it { is_expected.to permit_action :index }
      end

      context 'on a subject inside own\'s organization' do
        let(:tested_subject) { create :subject, organization: org }
        it { is_expected.to permit_action :show }
        it { is_expected.to forbid_edit_and_update_actions }
      end

      context 'on a subject outside of own\'s organization' do
        let(:tested_subject) { create :subject, organization: create(:organization) }
        it { is_expected.to forbid_action :show }
        it { is_expected.to forbid_edit_and_update_actions }
      end

      context 'on a new subject in own organization' do
        let(:tested_subject) { build :subject, organization: org }
        it { is_expected.to forbid_action :create }
      end

      context 'on a new subject outside of own organization' do
        let(:tested_subject) { build :subject, organization: create(:organization) }
        it { is_expected.to forbid_action :create }
      end
    end
  end

  describe 'scope' do
    RSpec.shared_examples :global_user_subject_scope do
      subject(:result) { SubjectPolicy::Scope.new(current_user, Subject).resolve }
      let(:org1) { create :organization }
      let(:org2) { create :organization }
      let(:subjects_in_org1) { create_list :subject, 3, organization: org1 }
      let(:subjects_in_org2) { create_list :subject, 3, organization: org2 }

      it 'returns all subjects from the first organization' do
        expect(result).to include(*subjects_in_org1)
      end

      it 'returns all subjects from second organization' do
        expect(result).to include(*subjects_in_org2)
      end
    end

    RSpec.shared_examples :local_user_subject_scope do
      subject(:result) { SubjectPolicy::Scope.new(current_user, Subject).resolve }
      let(:org2) { create :organization }
      let(:subjects_in_org) { create_list :subject, 3, organization: org }
      let(:subjects_in_org2) { create_list :subject, 3, organization: org2 }

      it 'includes all subjects from the first organization' do
        expect(result).to include(*subjects_in_org)
      end

      it 'does not include subjects from the second organization' do
        expect(result).not_to include(*subjects_in_org2)
      end
    end

    context 'As a Super Administrator' do
      let(:current_user) { create :super_admin }
      it_behaves_like :global_user_subject_scope
    end

    context 'As a Global Administrator' do
      let(:current_user) { create :global_admin }
      it_behaves_like :global_user_subject_scope
    end

    context 'As a Global Guest' do
      let(:current_user) { create :global_guest }
      it_behaves_like :global_user_subject_scope
    end

    context 'As a Global Researcher' do
      let(:current_user) { create :global_researcher }
      it_behaves_like :global_user_subject_scope
    end

    context 'As a Local Administrator' do
      let(:org) { create :organization }
      let(:current_user) { create :admin_of, organization: org }
      it_behaves_like :local_user_subject_scope
    end

    context 'As a Local Teacher' do
      let(:org) { create :organization }
      let(:current_user) { create :teacher_in, organization: org }
      it_behaves_like :local_user_subject_scope
    end

    context 'As a Local Guest' do
      let(:org) { create :organization }
      let(:current_user) { create :guest_in, organization: org }
      it_behaves_like :local_user_subject_scope
    end

    context 'As a Local Researcher' do
      let(:org) { create :organization }
      let(:current_user) { create :researcher_in, organization: org }
      it_behaves_like :local_user_subject_scope
    end

    context 'As a User with roles in multiple organizations' do
      subject(:result) { SubjectPolicy::Scope.new(current_user, Subject).resolve }

      let(:org1) { create :organization }
      let(:org2) { create :organization }
      let(:org3) { create :organization }
      let(:current_user) do
        u = create :admin_of, organization: org1
        u.add_role :teacher, org2
        u
      end

      let(:subjects_in_org1) { create_list :subject, 3, organization: org1 }
      let(:subjects_in_org2) { create_list :subject, 3, organization: org2 }
      let(:subjects_in_org3) { create_list :subject, 3, organization: org3 }

      it 'includes all subjects from the first organization' do
        expect(result).to include(*subjects_in_org1)
      end

      it 'includes all subjects from the second organization' do
        expect(result).to include(*subjects_in_org2)
      end

      it 'does not include subjects from a different organization' do
        expect(result).not_to include(*subjects_in_org3)
      end
    end
  end
end
