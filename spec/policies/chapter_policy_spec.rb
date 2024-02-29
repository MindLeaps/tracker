require 'rails_helper'

RSpec.describe ChapterPolicy do
  describe 'permissions' do
    subject { ChapterPolicy.new current_user, chapter }

    context 'as a Super Administrator' do
      let(:current_user) { create :super_admin }

      context 'on a Chapter Resource' do
        let(:chapter) { Chapter }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing chapter' do
        let(:chapter) { create :chapter }

        it { is_expected.to permit_action :show }
        it { is_expected.to permit_edit_and_update_actions }
      end

      context 'on a new chapter' do
        let(:chapter) { build :chapter }
        it { is_expected.to permit_action :create }
      end
    end

    context 'as a Global Administrator' do
      let(:current_user) { create :global_admin }

      context 'on a Chapter Resource' do
        let(:chapter) { Chapter }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing chapter' do
        let(:chapter) { create :chapter }

        it { is_expected.to permit_action :show }
        it { is_expected.to permit_edit_and_update_actions }
      end

      context 'on a new chapter' do
        let(:chapter) { build :chapter }
        it { is_expected.to permit_action :create }
      end
    end

    context 'as a Global Guest' do
      let(:current_user) { create :global_guest }

      context 'on a Chapter Resource' do
        let(:chapter) { Chapter }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing chapter' do
        let(:chapter) { create :chapter }

        it { is_expected.to permit_action :show }
        it { is_expected.to forbid_edit_and_update_actions }
      end

      context 'on a new chapter' do
        let(:chapter) { build :chapter }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Global Researcher' do
      let(:current_user) { create :global_researcher }

      context 'on a Chapter Resource' do
        let(:chapter) { Chapter }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing chapter' do
        let(:chapter) { create :chapter }

        it { is_expected.to permit_action :show }
        it { is_expected.to forbid_edit_and_update_actions }
      end

      context 'on a new chapter' do
        let(:chapter) { build :chapter }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Local Administrator' do
      let(:org) { create :organization }
      let(:current_user) { create :admin_of, organization: org }

      context 'on a Chapter Resource' do
        let(:chapter) { Chapter }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing chapter in own organization' do
        let(:chapter) { create :chapter, organization: org }

        it { is_expected.to permit_action :show }
        it { is_expected.to permit_edit_and_update_actions }
      end

      context 'on any existing chapter outside of own organization' do
        let(:chapter) { create :chapter, organization: create(:organization) }

        it { is_expected.to forbid_action :show }
        it { is_expected.to forbid_edit_and_update_actions }
      end

      context 'on a new chapter in own organization' do
        let(:chapter) { build :chapter, organization: org }
        it { is_expected.to permit_action :create }
      end

      context 'on a new chapter in own organization' do
        let(:chapter) { build :chapter, organization: create(:organization) }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Local Teacher' do
      let(:org) { create :organization }
      let(:current_user) { create :teacher_in, organization: org }

      context 'on a Chapter Resource' do
        let(:chapter) { Chapter }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing chapter in own organization' do
        let(:chapter) { create :chapter, organization: org }

        it { is_expected.to permit_action :show }
        it { is_expected.to forbid_edit_and_update_actions }
      end

      context 'on any existing chapter outside of own organization' do
        let(:chapter) { create :chapter, organization: create(:organization) }

        it { is_expected.to forbid_action :show }
        it { is_expected.to forbid_edit_and_update_actions }
      end

      context 'on a new chapter in own organization' do
        let(:chapter) { build :chapter, organization: org }
        it { is_expected.to forbid_action :create }
      end

      context 'on a new chapter in own organization' do
        let(:chapter) { build :chapter, organization: create(:organization) }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Local Guest' do
      let(:org) { create :organization }
      let(:current_user) { create :guest_in, organization: org }

      context 'on a Chapter Resource' do
        let(:chapter) { Chapter }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing chapter in own organization' do
        let(:chapter) { create :chapter, organization: org }

        it { is_expected.to permit_action :show }
        it { is_expected.to forbid_edit_and_update_actions }
      end

      context 'on any existing chapter outside of own organization' do
        let(:chapter) { create :chapter, organization: create(:organization) }

        it { is_expected.to forbid_action :show }
        it { is_expected.to forbid_edit_and_update_actions }
      end

      context 'on a new chapter in own organization' do
        let(:chapter) { build :chapter, organization: org }
        it { is_expected.to forbid_action :create }
      end

      context 'on a new chapter in own organization' do
        let(:chapter) { build :chapter, organization: create(:organization) }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Local Researcher' do
      let(:org) { create :organization }
      let(:current_user) { create :researcher_in, organization: org }

      context 'on a Chapter Resource' do
        let(:chapter) { Chapter }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing chapter in own organization' do
        let(:chapter) { create :chapter, organization: org }

        it { is_expected.to permit_action :show }
        it { is_expected.to forbid_edit_and_update_actions }
      end

      context 'on any existing chapter outside of own organization' do
        let(:chapter) { create :chapter, organization: create(:organization) }

        it { is_expected.to forbid_action :show }
        it { is_expected.to forbid_edit_and_update_actions }
      end

      context 'on a new chapter in own organization' do
        let(:chapter) { build :chapter, organization: org }
        it { is_expected.to forbid_action :create }
      end

      context 'on a new chapter in own organization' do
        let(:chapter) { build :chapter, organization: create(:organization) }
        it { is_expected.to forbid_action :create }
      end
    end
  end

  describe 'scope' do
    RSpec.shared_examples :global_user_chapter_scope do
      subject(:result) { ChapterPolicy::Scope.new(current_user, Chapter).resolve }
      let(:chapters1) { create_list :chapter, 3, organization: create(:organization) }
      let(:chapters2) { create_list :chapter, 3, organization: create(:organization) }
      let(:chapters3) { create_list :chapter, 3, organization: create(:organization) }

      it 'returns all chapters' do
        expect(result).to include(*chapters1, *chapters2, *chapters3)
      end
    end

    RSpec.shared_examples :local_user_chapter_scope do
      subject(:result) { ChapterPolicy::Scope.new(current_user, Chapter).resolve }
      let(:org2) { create :organization }
      let(:chapters1) { create_list :chapter, 3, organization: org }
      let(:chapters2) { create_list :chapter, 3, organization: org2 }

      it 'includes chapters from organizations where user has a role' do
        expect(result).to include(*chapters1)
      end

      it 'does not include chapters from organizations in which user does not have a role' do
        expect(result).not_to include(*chapters2)
      end
    end

    context 'As a Super Administrator' do
      let(:current_user) { create :super_admin }
      it_behaves_like :global_user_chapter_scope
    end

    context 'As a Global Administrator' do
      let(:current_user) { create :global_admin }
      it_behaves_like :global_user_chapter_scope
    end

    context 'As a Global Guest' do
      let(:current_user) { create :global_guest }
      it_behaves_like :global_user_chapter_scope
    end

    context 'As a Global Researcher' do
      let(:current_user) { create :global_researcher }
      it_behaves_like :global_user_chapter_scope
    end

    context 'As a Local Administrator' do
      let(:org) { create :organization }
      let(:current_user) { create :admin_of, organization: org }
      it_behaves_like :local_user_chapter_scope
    end

    context 'As a Local Teacher' do
      let(:org) { create :organization }
      let(:current_user) { create :teacher_in, organization: org }
      it_behaves_like :local_user_chapter_scope
    end

    context 'As a Local Guest' do
      let(:org) { create :organization }
      let(:current_user) { create :guest_in, organization: org }
      it_behaves_like :local_user_chapter_scope
    end

    context 'As a Local Researcher' do
      let(:org) { create :organization }
      let(:current_user) { create :researcher_in, organization: org }
      it_behaves_like :local_user_chapter_scope
    end

    context 'As a User with roles in multiple organizations' do
      subject(:result) { ChapterPolicy::Scope.new(current_user, Chapter).resolve }

      let(:org1) { create :organization }
      let(:org2) { create :organization }
      let(:org3) { create :organization }

      let(:chapters1) { create_list :chapter, 3, organization: org1 }
      let(:chapters2) { create_list :chapter, 3, organization: org2 }
      let(:chapters3) { create_list :chapter, 3, organization: org3 }

      let(:current_user) do
        u = create :admin_of, organization: org1
        u.add_role :teacher, org2
        u
      end

      it 'includes chapters from the organizations where user is a member' do
        expect(result).to include(*chapters1, *chapters2)
      end

      it 'does not include an chapters from organization where user is not a membet' do
        expect(result).not_to include(*chapters3)
      end
    end
  end
end
