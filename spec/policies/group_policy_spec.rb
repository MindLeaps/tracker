require 'rails_helper'

RSpec.describe GroupPolicy do
  describe 'permissions' do
    subject { GroupPolicy.new current_user, resource }

    context 'as a Super Administrator' do
      let(:current_user) { create :super_admin }
      context 'on any existing group' do
        let(:resource) { create :group }

        it { is_expected.to permit_actions %i[show destroy undelete] }
        it { is_expected.to permit_edit_and_update_actions }
      end

      context 'creating a new group' do
        let(:resource) { build :group }

        it { is_expected.to permit_new_and_create_actions }
      end
    end

    context 'as a Global Administrator' do
      let(:current_user) { create :global_admin }
      context 'on any existing group' do
        let(:resource) { create :group }

        it { is_expected.to permit_actions %i[show destroy undelete] }
        it { is_expected.to permit_edit_and_update_actions }
      end

      context 'creating a new group' do
        let(:resource) { build :group }

        it { is_expected.to permit_new_and_create_actions }
      end
    end

    context 'as a Global Guest' do
      let(:current_user) { create :global_guest }

      context 'on any existing group' do
        let(:resource) { create :group }

        it { is_expected.to permit_action :show }
        it { is_expected.to forbid_actions %i[destroy undelete] }
        it { is_expected.to forbid_edit_and_update_actions }
      end

      context 'creating a new group' do
        let(:resource) { build :group }

        it { is_expected.to forbid_new_and_create_actions }
      end
    end

    context 'as a Global Researcher' do
      let(:current_user) { create :global_guest }

      context 'on any existing group' do
        let(:resource) { create :group }

        it { is_expected.to permit_action :show }
        it { is_expected.to forbid_actions %i[destroy undelete] }
        it { is_expected.to forbid_edit_and_update_actions }
      end

      context 'creating a new group' do
        let(:resource) { build :group }

        it { is_expected.to forbid_new_and_create_actions }
      end
    end

    context 'as a Local Administrator' do
      let(:org) { create :organization }
      let(:current_user) { create :admin_of, organization: org }

      context 'on an existing group in the user\'s organization' do
        let(:chapter) { create :chapter, organization: org }
        let(:resource) { create :group, chapter: }

        it { is_expected.to permit_actions %i[show destroy undelete] }
        it { is_expected.to permit_edit_and_update_actions }
      end

      context 'on an existing group in a different organization' do
        let(:chapter) { create :chapter, organization: create(:organization) }
        let(:resource) { create :group, chapter: }

        it { is_expected.to forbid_actions %i[show destroy undelete] }
        it { is_expected.to forbid_edit_and_update_actions }
      end

      context 'creating a new group in own organization' do
        let(:chapter) { create :chapter, organization: org }
        let(:resource) { build :group, chapter: }

        it { is_expected.to permit_new_and_create_actions }
      end

      context 'creating a new group in a different organization' do
        let(:resource) { build :group }

        it { is_expected.to permit_action :new }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Local Teacher' do
      let(:org) { create :organization }
      let(:current_user) { create :admin_of, organization: org }

      context 'on an existing group in own organization' do
        let(:chapter) { create :chapter, organization: org }
        let(:resource) { create :group, chapter: }

        it { is_expected.to permit_actions %i[show destroy undelete] }
        it { is_expected.to permit_edit_and_update_actions }
      end

      context 'on an existing group in a different organization' do
        let(:chapter) { create :chapter, organization: create(:organization) }
        let(:resource) { create :group, chapter: }

        it { is_expected.to forbid_actions %i[show destroy undelete] }
        it { is_expected.to forbid_edit_and_update_actions }
      end

      context 'creating a new group in own organization' do
        let(:chapter) { create :chapter, organization: org }
        let(:resource) { build :group, chapter: }

        it { is_expected.to permit_new_and_create_actions }
      end

      context 'creating a new group in a different organization' do
        let(:resource) { build :group }

        it { is_expected.to permit_action :new }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Local Guest' do
      let(:org) { create :organization }
      let(:current_user) { create :guest_in, organization: org }

      context 'on an existing group in own organization' do
        let(:chapter) { create :chapter, organization: org }
        let(:resource) { create :group, chapter: }

        it { is_expected.to permit_action :show }
        it { is_expected.to forbid_actions %i[destroy undelete] }
        it { is_expected.to forbid_edit_and_update_actions }
      end

      context 'on an existing group in a different organization' do
        let(:chapter) { create :chapter, organization: create(:organization) }
        let(:resource) { create :group, chapter: }

        it { is_expected.to forbid_actions %i[show destroy undelete] }
        it { is_expected.to forbid_edit_and_update_actions }
      end

      context 'creating a new group in own organization' do
        let(:chapter) { create :chapter, organization: org }
        let(:resource) { build :group, chapter: }

        it { is_expected.to forbid_new_and_create_actions }
      end

      context 'creating a new group in a different organization' do
        let(:resource) { build :group }

        it { is_expected.to forbid_action :new }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Local Researcher' do
      let(:org) { create :organization }
      let(:current_user) { create :researcher_in, organization: org }

      context 'on an existing group in own organization' do
        let(:chapter) { create :chapter, organization: org }
        let(:resource) { create :group, chapter: }

        it { is_expected.to permit_action :show }
        it { is_expected.to forbid_actions %i[destroy undelete] }
        it { is_expected.to forbid_edit_and_update_actions }
      end

      context 'on an existing group in a different organization' do
        let(:chapter) { create :chapter, organization: create(:organization) }
        let(:resource) { create :group, chapter: }

        it { is_expected.to forbid_actions %i[show destroy undelete] }
        it { is_expected.to forbid_edit_and_update_actions }
      end

      context 'creating a new group in own organization' do
        let(:chapter) { create :chapter, organization: org }
        let(:resource) { build :group, chapter: }

        it { is_expected.to forbid_new_and_create_actions }
      end

      context 'creating a new group in a different organization' do
        let(:resource) { build :group }

        it { is_expected.to forbid_action :new }
        it { is_expected.to forbid_action :create }
      end
    end
  end

  describe 'scope' do
    subject(:result) { GroupPolicy::Scope.new(current_user, Group).resolve }
    subject(:summary_result) { GroupPolicy::Scope.new(current_user, GroupSummary).resolve }
    let(:groups) { create_list :group, 5 }
    let(:summaries) { GroupSummary.all }

    context 'As a Super Administrator' do
      let(:current_user) { create :super_admin }

      it 'returns all groups' do
        expect(result).to include(*groups)
        expect(summary_result).to include(*summaries)
      end
    end

    context 'As a Global Administrator' do
      let(:current_user) { create :global_admin }

      it 'returns all groups' do
        expect(result).to include(*groups)
        expect(summary_result).to include(*summaries)
      end
    end

    context 'As a Global Guest' do
      let(:current_user) { create :global_guest }

      it 'returns all groups' do
        expect(result).to include(*groups)
        expect(summary_result).to include(*summaries)
      end
    end

    context 'As a Global Researcher' do
      let(:current_user) { create :global_researcher }

      it 'returns all groups' do
        expect(result).to include(*groups)
        expect(summary_result).to include(*summaries)
      end
    end

    context 'As a Local Administrator' do
      let(:current_user) { create :admin_of, organization: groups[0].chapter.organization }
      let(:another_group) { create :group, chapter: groups[0].chapter }

      it 'returns only groups from own organization' do
        expect(result).to include groups[0], another_group
        expect(result.length).to eq 2
        expect(summary_result.length).to eq 2
      end
    end

    context 'As a Local Teacher' do
      let(:current_user) { create :teacher_in, organization: groups[1].chapter.organization }
      let(:another_group) { create :group, chapter: groups[1].chapter }

      it 'returns only groups from own organization' do
        expect(result).to include groups[1], another_group
        expect(result.length).to eq 2
        expect(summary_result.length).to eq 2
      end
    end

    context 'As a Local Guest' do
      let(:current_user) { create :guest_in, organization: groups[2].chapter.organization }
      let(:another_group) { create :group, chapter: groups[2].chapter }

      it 'returns only groups from own organization' do
        expect(result).to include groups[2], another_group
        expect(result.length).to eq 2
        expect(summary_result.length).to eq 2
      end
    end

    context 'As a Local Researcher' do
      let(:current_user) { create :guest_in, organization: groups[3].chapter.organization }
      let(:another_group) { create :group, chapter: groups[3].chapter }

      it 'returns only groups from own organization' do
        expect(result).to include groups[3], another_group
        expect(result.length).to eq 2
        expect(summary_result.length).to eq 2
      end
    end

    context 'As a Local Administrator, and Researcher in a different organization' do
      let(:current_user) { create :admin_of, organization: groups[0].chapter.organization }

      it 'returns only groups from own organization' do
        current_user.add_role :researcher, groups[1].chapter.organization
        expect(result).to include groups[0], groups[1]
        expect(result.length).to eq 2
        expect(summary_result.length).to eq 2
      end
    end
  end
end
