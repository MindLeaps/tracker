require 'rails_helper'

RSpec.describe 'User interacts with lessons' do
  context 'As a global administrator' do
    include_context 'login_with_admin'

    before :all do
      create :group, group_name: 'Lesson Group'
    end

    it 'creates a lesson' do
      visit '/'
      click_link 'Lessons'

      select 'Lesson Group', from: 'lesson_group_id'
      click_button 'Create'

      expect(page).to have_content 'Lesson successfully created'
    end
  end
end
