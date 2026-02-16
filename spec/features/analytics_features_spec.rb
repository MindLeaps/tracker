require 'rails_helper'

RSpec.describe 'User interacts with Analytics' do
  include_context 'login_with_global_admin'

  describe 'Viewing Analytics' do
    before :each do
      @chapter = create :chapter
      @group = create :group, chapter: @chapter
      @deleted_group = create :group, chapter: @chapter, deleted_at: Time.zone.now
      @student = create :graded_student, organization: @group.chapter.organization, groups: [@group], grades: { 'Memorization' => [3, 4, 5, 6, 7], 'Grit' => [2, 3, 2, 4, 5] }
      @other_student = create :graded_student, organization: @group.chapter.organization, groups: [@group], grades: { 'Memorization' => [3, 4, 5, 6, 7], 'Grit' => [2, 3, 2, 4, 5] }
      @organization = @chapter.organization
    end

    it 'displays general, subject, and group analytics', js: true do
      visit '/'
      click_link 'Analytics'
      select @organization.organization_name, from: 'organization_select'
      click_link 'Filter'
      expect(page).to have_content('General analytics')
      expect(page).to have_link('Subject analytics')
      expect(page).to have_link('Group analytics')

      # Using regex whitespace match here because capybara fails to match a wrapped line in HighCharts SVG
      expect(page).to have_content(/Quantity(\s*)of(\s*)Data(\s*)Collected(\s*)By(\s*)Month/)
      expect(page).to have_content(/Histogram(\s*)of(\s*)student(\s*)performance(\s*)values/)
      expect(page).to have_content(/Performance(\s*)change(\s*)throughout(\s*)the(\s*)program(\s*)by(\s*)student/)
      expect(page).to have_content(/Performance(\s*)change(\s*)throughout(\s*)the(\s*)program(\s*)separated(\s*)by(\s*)gender/)
      expect(page).to have_content(/Average(\s*)performance(\s*)per(\s*)group(\s*)versus(\s*)time(\s*)in(\s*)program/)

      click_link 'Subject analytics'
      select @organization.organization_name, from: 'organization_select'
      click_link 'Filter'
      expect(page).to have_content 'Memorization'
      expect(page).to have_content 'Grit'

      click_link 'Group analytics'
      select @organization.organization_name, from: 'organization_select'
      click_link 'Filter'
      expect(page).to have_content('Download PNG')
    end

    it 'displays students only when groups are selected', js: true do
      visit '/'
      click_link 'Analytics'

      student_select = find '#student_id'

      expect(student_select).to have_selector('option', count: 1)
      expect(student_select.find('option').text).to eq 'Select groups to load students'

      multiselect_button = find('button[data-action="click->multiselect#toggleMenu"]')
      multiselect_button.click

      find('div[data-multiselect-target="option"]', text: @group.group_name).click

      student_select.reload
      expect(student_select).to have_selector('option', count: @group.students.count + 1) # for option 'All'
    end
  end
end
