require 'rails_helper'

RSpec.describe 'User interacts with Analytics' do
  include_context 'login_with_global_admin'

  describe 'Viewing Analytics' do
    before :each do
      @chapter = create :chapter
      @group = create :group, chapter: @chapter
      @deleted_group = create :group, chapter: @chapter, deleted_at: Time.zone.now
      @student = create :graded_student, organization: @group.chapter.organization, groups: [@group], grades: { 'Memorization' => [3, 4, 5, 6, 7], 'Grit' => [2, 3, 2, 4, 5] }
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
      expect(page).to have_content(@group.group_chapter_name)
    end
  end
end
