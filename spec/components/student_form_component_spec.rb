require 'rails_helper'

RSpec.describe StudentFormComponent, type: :component do
  before :all do
    # Bullet gives false positives for these tests
    Bullet.enable = false
  end

  before :each do
    @user_org = create :organization
    @user_org_chapter = create :chapter, organization: @user_org
    @user_org_group = create :group, chapter: @user_org_chapter
    @user_org_tag = create :tag, organization: @user_org, shared: false

    @other_org = create :organization
    @other_org_chapter = create :chapter, organization: @other_org
    @other_org_group = create :group, chapter: @other_org_chapter
    @other_org_tag = create :tag, organization: @other_org, shared: false

    @user = create :admin_of, organization: @user_org
  end

  describe :chapter_groups do
    it 'scopes the groups to include only ones that belong to the users organization' do
      expect(
        StudentFormComponent.new(student: Student.new, action: :create, current_user: @user).chapter_groups.flat_map(&:groups).map(&:id)
      ).to eq([@user_org_group.id])
    end
  end

  describe :permitted_tags do
    it 'scopes Tags to include only ones that belong to the users organization' do
      expect(
        StudentFormComponent.new(student: Student.new, action: :create, current_user: @user).permitted_tags.map(&:id)
      ).to eq([@user_org_tag.id])
    end
  end

  after :all do
    Bullet.enable = true
  end
end
