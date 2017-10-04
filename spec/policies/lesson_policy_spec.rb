# frozen_string_literal: true

require 'rails_helper'
RSpec.describe LessonPolicy do
  describe 'permissions' do
    subject { LessonPolicy.new current_user, lesson }

    context 'as a Super Administrator' do
      let(:current_user) { create :super_admin }

      context 'on a Lesson Resource' do
        let(:lesson) { Lesson }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing lesson' do
        let(:lesson) { Lesson.create }
        it { is_expected.to permit_action :show }
      end

      context 'on a new lesson' do
        let(:lesson) { build :lesson }
        it { is_expected.to permit_action :create }
      end
    end

    context 'as a Global Administrator' do
      let(:current_user) { create :global_admin }

      context 'on a Lesson Resource' do
        let(:lesson) { Lesson }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing lesson' do
        let(:lesson) { Lesson.create }
        it { is_expected.to permit_action :show }
      end

      context 'on a new lesson' do
        let(:lesson) { build :lesson }
        it { is_expected.to permit_action :create }
      end
    end

    context 'as a Global Guest' do
      let(:current_user) { create :global_guest }

      context 'on a Lesson Resource' do
        let(:lesson) { Lesson }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing lesson' do
        let(:lesson) { Lesson.create }
        it { is_expected.to permit_action :show }
      end

      context 'on a new lesson' do
        let(:lesson) { build :lesson }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Global Researcher' do
      let(:current_user) { create :global_researcher }

      context 'on a Lesson Resource' do
        let(:lesson) { Lesson }
        it { is_expected.to permit_action :index }
      end

      context 'on any existing lesson' do
        let(:lesson) { Lesson.create }
        it { is_expected.to permit_action :show }
      end

      context 'on a new lesson' do
        let(:lesson) { build :lesson }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Local Administrator' do
      let(:org) { create :organization }
      let(:chapter) { create :chapter, organization: org }
      let(:group) { create :group, chapter: chapter }
      let(:current_user) { create :admin_of, organization: org }

      context 'on a Lesson Resource' do
        let(:lesson) { Lesson }
        it { is_expected.to permit_action :index }
      end

      context 'on a lesson inside own\'s organization' do
        let(:lesson) { create :lesson, group: group }
        it { is_expected.to permit_action :show }
      end

      context 'on a lesson outside of own\'s organization' do
        let(:lesson) { create :lesson, group: create(:group) }
        it { is_expected.to forbid_action :show }
      end

      context 'on a new lesson in own organization' do
        let(:lesson) { build :lesson, group: group }
        it { is_expected.to permit_action :create }
      end

      context 'on a new lesson outside of own organization' do
        let(:lesson) { build :lesson }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Local Teacher' do
      let(:org) { create :organization }
      let(:chapter) { create :chapter, organization: org }
      let(:group) { create :group, chapter: chapter }
      let(:current_user) { create :teacher_in, organization: org }

      context 'on a User Resource' do
        let(:lesson) { Lesson }
        it { is_expected.to permit_action :index }
      end

      context 'on a lesson inside own\'s organization' do
        let(:lesson) { create :lesson, group: group }
        it { is_expected.to permit_action :show }
      end

      context 'on a lesson outside of own\'s organization' do
        let(:lesson) { create :lesson }
        it { is_expected.to forbid_action :show }
      end

      context 'on a new lesson in own organization' do
        let(:lesson) { build :lesson, group: group }
        it { is_expected.to permit_action :create }
      end

      context 'on a new lesson outside of own organization' do
        let(:lesson) { build :lesson }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Local Guest' do
      let(:org) { create :organization }
      let(:chapter) { create :chapter, organization: org }
      let(:group) { create :group, chapter: chapter }
      let(:current_user) { create :guest_in, organization: org }

      context 'on a User Resource' do
        let(:lesson) { Lesson }
        it { is_expected.to permit_action :index }
      end

      context 'on a lesson inside own\'s organization' do
        let(:lesson) { create :lesson, group: group }
        it { is_expected.to permit_action :show }
      end

      context 'on a lesson outside of own\'s organization' do
        let(:lesson) { create :lesson }
        it { is_expected.to forbid_action :show }
      end

      context 'on a new lesson in own organization' do
        let(:lesson) { build :lesson, group: group }
        it { is_expected.to forbid_action :create }
      end

      context 'on a new lesson outside of own organization' do
        let(:lesson) { build :lesson }
        it { is_expected.to forbid_action :create }
      end
    end

    context 'as a Local Researcher' do
      let(:org) { create :organization }
      let(:chapter) { create :chapter, organization: org }
      let(:group) { create :group, chapter: chapter }
      let(:current_user) { create :researcher_in, organization: org }

      context 'on a User Resource' do
        let(:lesson) { Lesson }
        it { is_expected.to permit_action :index }
      end

      context 'on a lesson inside own\'s organization' do
        let(:lesson) { create :lesson, group: group }
        it { is_expected.to permit_action :show }
      end

      context 'on a lesson outside of own\'s organization' do
        let(:lesson) { create :lesson }
        it { is_expected.to forbid_action :show }
      end

      context 'on a new lesson in own organization' do
        let(:lesson) { build :lesson, group: group }
        it { is_expected.to forbid_action :create }
      end

      context 'on a new lesson outside of own organization' do
        let(:lesson) { build :lesson }
        it { is_expected.to forbid_action :create }
      end
    end
  end

  describe 'scope' do
    RSpec.shared_examples :global_user_lesson_scope do
      subject(:result) { LessonPolicy::Scope.new(current_user, Lesson).resolve }
      let(:org1) { create :organization }
      let(:org2) { create :organization }
      let(:lessons_in_org1) { create_list :lesson, 3, group: create(:group, chapter: create(:chapter, organization: org1)) }
      let(:lessons_in_org2) { create_list :lesson, 3, group: create(:group, chapter: create(:chapter, organization: org2)) }

      it 'returns all lessons from the first organization' do
        expect(result).to include(*lessons_in_org1)
      end

      it 'returns all lessons from second organization' do
        expect(result).to include(*lessons_in_org2)
      end
    end

    RSpec.shared_examples :local_user_lesson_scope do
      subject(:result) { LessonPolicy::Scope.new(current_user, Lesson).resolve }
      let(:org2) { create :organization }
      let(:lessons_in_org) { create_list :lesson, 3, group: create(:group, chapter: create(:chapter, organization: org)) }
      let(:lessons_in_org2) { create_list :lesson, 3, group: create(:group, chapter: create(:chapter, organization: org2)) }

      it 'includes all lessons from the first organization' do
        expect(result).to include(*lessons_in_org)
      end

      it 'does not include lessons from the second organization' do
        expect(result).not_to include(*lessons_in_org2)
      end
    end

    context 'As a Super Administrator' do
      let(:current_user) { create :super_admin }
      it_behaves_like :global_user_lesson_scope
    end

    context 'As a Global Administrator' do
      let(:current_user) { create :global_admin }
      it_behaves_like :global_user_lesson_scope
    end

    context 'As a Global Guest' do
      let(:current_user) { create :global_guest }
      it_behaves_like :global_user_lesson_scope
    end

    context 'As a Global Researcher' do
      let(:current_user) { create :global_researcher }
      it_behaves_like :global_user_lesson_scope
    end

    context 'As a Local Administrator' do
      let(:org) { create :organization }
      let(:current_user) { create :admin_of, organization: org }
      it_behaves_like :local_user_lesson_scope
    end

    context 'As a Local Teacher' do
      let(:org) { create :organization }
      let(:current_user) { create :teacher_in, organization: org }
      it_behaves_like :local_user_lesson_scope
    end

    context 'As a Local Guest' do
      let(:org) { create :organization }
      let(:current_user) { create :guest_in, organization: org }
      it_behaves_like :local_user_lesson_scope
    end

    context 'As a Local Researcher' do
      let(:org) { create :organization }
      let(:current_user) { create :researcher_in, organization: org }
      it_behaves_like :local_user_lesson_scope
    end

    context 'As a User with roles in multiple organizations' do
      subject(:result) { LessonPolicy::Scope.new(current_user, Lesson).resolve }

      let(:org1) { create :organization }
      let(:org2) { create :organization }
      let(:current_user) do
        u = create :admin_of, organization: org1
        u.add_role :teacher, org2
        u
      end

      let(:lessons_in_org1) { create_list :lesson, 3, group: create(:group, chapter: create(:chapter, organization: org1)) }
      let(:lessons_in_org2) { create_list :lesson, 3, group: create(:group, chapter: create(:chapter, organization: org2)) }
      let(:lessons_in_org3) { create_list :lesson, 3, group: create(:group, chapter: create(:chapter, organization: create(:organization))) }

      it 'includes all lessons from the first organization' do
        expect(result).to include(*lessons_in_org1)
      end

      it 'includes all lessons from the second organization' do
        expect(result).to include(*lessons_in_org2)
      end

      it 'does not include lessons from a different organization' do
        expect(result).not_to include(*lessons_in_org3)
      end
    end
  end
end
