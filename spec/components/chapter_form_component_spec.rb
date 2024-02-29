require 'rails_helper'

RSpec.describe ChapterFormComponent, type: :component do
  before :each do
    @org1 = create :organization
    @org2 = create :organization
  end

  it 'scopes organizations by user permissions' do
    user = create :admin_of, organization: @org1
    expect(
      ChapterFormComponent.new(chapter: Chapter.new, action: 'create', current_user: user).permitted_organizations.map(&:id)
    ).to eq([@org1.id])
  end
end
