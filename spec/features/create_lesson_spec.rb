require 'rails_helper'

RSpec.describe 'User creates a lesson' do
  include_context 'login_with_admin'

  before :each do
    create :group, group_name: 'Lesson Group'
  end

  it 'successfuly' do
    visit '/'
    click_link 'Lessons'

    select 'Lesson Group', from: 'lesson_group_id'
    click_button 'Create'

    expect(page).to have_css 'tr.lesson-row'
  end
end
