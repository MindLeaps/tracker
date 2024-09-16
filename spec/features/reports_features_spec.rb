require 'rails_helper'

RSpec.describe 'User interacts with Reports' do
  include_context 'login_with_global_admin'

  describe 'Viewing Reports' do
    before :each do
      @organization = create :organization, organization_name: 'Report organization'
      @chapter = create :chapter, chapter_name: 'Report Chapter', organization: @organization
      @group = create :group, chapter: @chapter, group_name: 'Report Group'
      @student = create :graded_student, group: @group, grades: { 'Memorization' => [3, 4, 5, 6, 7], 'Grit' => [2, 3, 2, 4, 5] }
      create :enrollment, group: @group, student: @student, active_since: 1.year.ago
    end

    it 'displays group and student averages', js: true do
      visit "/reports/groups/#{@group.id}"

      expect(page).to have_content('Group report')
      expect(page).to have_content('Group averages')
      expect(page).to have_selector('#group_history')
      expect(page).to have_selector('#last_30')
      expect(page).to have_content(@student.first_name)
    end
  end
end
