require 'rails_helper'
RSpec.describe SkillPolicy do
  describe 'permissions' do
    subject { SkillPolicy.new current_user, skill }

    context 'as a Super Administrator' do
      let(:current_user) { create :super_admin }

      context 'on a Skill Resource' do
        let(:skill) { Skill }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing skill' do
        let(:skill) { create :skill }
        it { is_expected.to permit_action :show }
        it { is_expected.to permit_action :destroy }
        it { is_expected.to permit_action :undelete }
      end

      context 'on a new skill' do
        let(:skill) { build :skill }
        it { is_expected.to permit_new_and_create_actions }
      end
    end

    context 'as a Global Administrator' do
      let(:current_user) { create :global_admin }

      context 'on a Skill Resource' do
        let(:skill) { Skill }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing skill' do
        let(:skill) { create :skill }
        it { is_expected.to permit_action :show }
        it { is_expected.to permit_action :destroy }
        it { is_expected.to permit_action :undelete }
      end

      context 'on a new skill' do
        let(:skill) { build :skill }
        it { is_expected.to permit_new_and_create_actions }
      end
    end

    context 'as a Global Guest' do
      let(:current_user) { create :global_guest }

      context 'on a Skill Resource' do
        let(:skill) { Skill }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing skill' do
        let(:skill) { create :skill }
        it { is_expected.to permit_action :show }
        it { is_expected.to forbid_action :destroy }
        it { is_expected.to forbid_action :undelete }
      end

      context 'on a new skill' do
        let(:skill) { build :skill }
        it { is_expected.to forbid_new_and_create_actions }
      end
    end

    context 'as a Global Researcher' do
      let(:current_user) { create :global_researcher }

      context 'on a Skill Resource' do
        let(:skill) { Skill }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing skill' do
        let(:skill) { create :skill }
        it { is_expected.to permit_action :show }
        it { is_expected.to forbid_action :destroy }
        it { is_expected.to forbid_action :undelete }
      end

      context 'on a new skill' do
        let(:skill) { build :skill }
        it { is_expected.to forbid_new_and_create_actions }
      end
    end

    context 'as a Local Administrator' do
      let(:org) { create :organization }
      let(:current_user) { create :admin_of, organization: org }

      context 'on a Skill Resource' do
        let(:skill) { Skill }
        it { is_expected.to permit_action :index }
      end

      context 'on a skill inside own\'s organization' do
        let(:skill) { create :skill, organization: org }
        it { is_expected.to permit_action :show }
        it { is_expected.to permit_action :destroy }
        it { is_expected.to permit_action :undelete }
      end

      context 'on a skill outside of own\'s organization' do
        let(:skill) { create :skill, organization: create(:organization) }
        it { is_expected.to forbid_action :show }
        it { is_expected.to forbid_action :destroy }
        it { is_expected.to forbid_action :undelete }
      end

      context 'on a new skill in own organization' do
        let(:skill) { build :skill, organization: org }
        it { is_expected.to permit_new_and_create_actions }
      end

      context 'on a new skill outside of own organization' do
        let(:skill) { build :skill, organization: create(:organization) }
        it { is_expected.to forbid_action :create }
      end

      context 'on a skill belonging to a different organization, but used in the subject from own organization' do
        let(:subject1) { create :subject, organization: org }
        let(:skill) { create :skill_in_subject, organization: create(:organization), subject: subject1 }

        it { is_expected.to permit_action :show }
        it { is_expected.to forbid_action :destroy }
        it { is_expected.to forbid_action :undelete }
      end
    end

    context 'as a Local Teacher' do
      let(:org) { create :organization }
      let(:current_user) { create :teacher_in, organization: org }

      context 'on a Skill Resource' do
        let(:skill) { Skill }
        it { is_expected.to permit_action :index }
      end

      context 'on a skill inside own\'s organization' do
        let(:skill) { create :skill, organization: org }
        it { is_expected.to permit_action :show }
      end

      context 'on a skill outside of own\'s organization' do
        let(:skill) { create :skill, organization: create(:organization) }
        it { is_expected.to forbid_action :show }
      end

      context 'on a new skill in own organization' do
        let(:skill) { build :skill, organization: org }
        it { is_expected.to forbid_new_and_create_actions }
      end

      context 'on a new skill outside of own organization' do
        let(:skill) { build :skill, organization: create(:organization) }
        it { is_expected.to forbid_action :create }
      end

      context 'on a skill belonging to a different organization, but used in the subject from own organization' do
        let(:subject1) { create :subject, organization: org }
        let(:skill) { create :skill_in_subject, organization: create(:organization), subject: subject1 }

        it { is_expected.to permit_action :show }
      end
    end

    context 'as a Local Guest' do
      let(:org) { create :organization }
      let(:current_user) { create :guest_in, organization: org }

      context 'on a Skill Resource' do
        let(:skill) { Skill }
        it { is_expected.to permit_action :index }
      end

      context 'on a skill inside own\'s organization' do
        let(:skill) { create :skill, organization: org }
        it { is_expected.to permit_action :show }
      end

      context 'on a skill outside of own\'s organization' do
        let(:skill) { create :skill, organization: create(:organization) }
        it { is_expected.to forbid_action :show }
      end

      context 'on a new skill in own organization' do
        let(:skill) { build :skill, organization: org }
        it { is_expected.to forbid_new_and_create_actions }
      end

      context 'on a new skill outside of own organization' do
        let(:skill) { build :skill, organization: create(:organization) }
        it { is_expected.to forbid_action :create }
      end

      context 'on a skill belonging to a different organization, but used in the subject from own organization' do
        let(:subject1) { create :subject, organization: org }
        let(:skill) { create :skill_in_subject, organization: create(:organization), subject: subject1 }

        it { is_expected.to permit_action :show }
      end
    end

    context 'as a Local Researcher' do
      let(:org) { create :organization }
      let(:current_user) { create :researcher_in, organization: org }

      context 'on a Skill Resource' do
        let(:skill) { Skill }
        it { is_expected.to permit_action :index }
      end

      context 'on a skill inside own\'s organization' do
        let(:skill) { create :skill, organization: org }
        it { is_expected.to permit_action :show }
      end

      context 'on a skill outside of own\'s organization' do
        let(:skill) { create :skill, organization: create(:organization) }
        it { is_expected.to forbid_action :show }
      end

      context 'on a new skill in own organization' do
        let(:skill) { build :skill, organization: org }
        it { is_expected.to forbid_new_and_create_actions }
      end

      context 'on a new skill outside of own organization' do
        let(:skill) { build :skill, organization: create(:organization) }
        it { is_expected.to forbid_action :create }
      end

      context 'on a skill belonging to a different organization, but used in the subject from own organization' do
        let(:subject1) { create :subject, organization: org }
        let(:skill) { create :skill_in_subject, organization: create(:organization), subject: subject1 }

        it { is_expected.to permit_action :show }
      end
    end
  end

  describe 'scope' do
    RSpec.shared_examples :global_user_skill_scope do
      subject(:result) { SkillPolicy::Scope.new(current_user, Skill).resolve }
      let(:org1) { create :organization }
      let(:org2) { create :organization }
      let(:skills_in_org1) { create_list :skill, 3, organization: org1 }
      let(:skills_in_org2) { create_list :skill, 3, organization: org2 }

      it 'returns all skills from the first organization' do
        expect(result).to include(*skills_in_org1)
      end

      it 'returns all skills from second organization' do
        expect(result).to include(*skills_in_org2)
      end
    end

    RSpec.shared_examples :local_user_skill_scope do
      subject(:result) { SkillPolicy::Scope.new(current_user, Skill).resolve }
      let!(:org2) { create :organization }
      let!(:skill_subject) { create :subject, organization: org }
      let!(:skills_in_org) { create_list :skill, 3, organization: org }
      let!(:skills_in_org2) { create_list :skill, 3, organization: org2 }
      let!(:skills_in_org2_used_in_subject) { create_list :skill_in_subject, 3, organization: org2, subject: skill_subject }

      it 'includes all skills from the first organization' do
        expect(result).to include(*skills_in_org)
      end

      it 'does not include skills from the second organization' do
        expect(result).not_to include(*skills_in_org2)
      end

      it 'includes skills from the second organization that are used in the subject from first organization' do
        expect(result).to include(*skills_in_org2_used_in_subject)
      end
    end

    context 'As a Super Administrator' do
      let(:current_user) { create :super_admin }
      it_behaves_like :global_user_skill_scope
    end

    context 'As a Global Administrator' do
      let(:current_user) { create :global_admin }
      it_behaves_like :global_user_skill_scope
    end

    context 'As a Global Guest' do
      let(:current_user) { create :global_guest }
      it_behaves_like :global_user_skill_scope
    end

    context 'As a Global Researcher' do
      let(:current_user) { create :global_researcher }
      it_behaves_like :global_user_skill_scope
    end

    context 'As a Local Administrator' do
      let(:org) { create :organization }
      let(:current_user) { create :admin_of, organization: org }
      it_behaves_like :local_user_skill_scope
    end

    context 'As a Local Teacher' do
      let(:org) { create :organization }
      let(:current_user) { create :teacher_in, organization: org }
      it_behaves_like :local_user_skill_scope
    end

    context 'As a Local Guest' do
      let(:org) { create :organization }
      let(:current_user) { create :guest_in, organization: org }
      it_behaves_like :local_user_skill_scope
    end

    context 'As a Local Researcher' do
      let(:org) { create :organization }
      let(:current_user) { create :researcher_in, organization: org }
      it_behaves_like :local_user_skill_scope
    end

    context 'As a User with roles in multiple organizations' do
      subject(:result) { SkillPolicy::Scope.new(current_user, Skill).resolve }

      let(:org1) { create :organization }
      let(:org2) { create :organization }
      let(:org3) { create :organization }
      let(:current_user) do
        u = create :admin_of, organization: org1
        u.add_role :teacher, org2
        u
      end

      let(:skills_in_org1) { create_list :skill, 3, organization: org1 }
      let(:skills_in_org2) { create_list :skill, 3, organization: org2 }
      let(:skills_in_org3) { create_list :skill, 3, organization: org3 }

      it 'includes all skills from the first organization' do
        expect(result).to include(*skills_in_org1)
      end

      it 'includes all skills from the second organization' do
        expect(result).to include(*skills_in_org2)
      end

      it 'does not include skills from a different organization' do
        expect(result).not_to include(*skills_in_org3)
      end
    end
  end
end
