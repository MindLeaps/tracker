# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupFormComponent, type: :component do
  before :each do
    @chapters = create_list :chapter, 2
  end

  it 'scopes chapters by user permissions' do
    user = create :admin_of, organization: @chapters[0].organization
    expect(
      GroupFormComponent.new(group: Chapter.new, action: :create, current_user: user).permitted_chapters.map(&:id)
    ).to eq([@chapters[0].id])
  end
end
