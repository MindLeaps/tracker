require 'rails_helper'

RSpec.describe 'User interacts with Reports' do
  include_context 'login_with_global_admin'

  describe 'Viewing Reports' do
    before :each do
      @organization = create :organization, organization_name: 'Report organization'
      @first_subject = create :subject, organization: @organization
      @second_subject = create :subject, organization: @organization
      @first_skill = create :skill_with_descriptors, subject: @first_subject, skill_name: 'First Skill'
      @second_skill = create :skill_with_descriptors, subject: @second_subject, skill_name: 'Second Skill'
      @chapter = create :chapter, chapter_name: 'Report Chapter', organization: @organization
      @group = create :group, chapter: @chapter, group_name: 'Report Group'
      @empty_group = create :group, chapter: @chapter, group_name: 'Empty Report Group'
      @first_student = create :graded_student, organization: @group, groups: [@group], subject: @first_subject, grades: { 'First Skill' => [1, 2, 3] }
      @second_student = create :graded_student, organization: @group, groups: [@group], subject: @second_subject, grades: { 'Second Skill' => [1, 2, 3] }
    end

    it 'displays group and student averages', js: true, skip: 'Fails because we cannot close an open print preview window' do
      visit "/reports/groups/#{@group.id}"

      expect(page).to have_content("Group Report - #{@group.group_name}")
      expect(page).to have_content('Students')
      expect(page).to have_content('Group enrollments')
      expect(page).to have_content(@first_subject.subject_name)
      expect(page).to have_content(@second_subject.subject_name)
      expect(page).to have_content('Average performance for last 30 lessons')
      expect(page).to have_content('Group history')
      expect(page).to have_content('Group attendance')
      expect(page).to have_content('Average performance for the students across lessons')

      expect(page).to have_content(@first_student.proper_name)
      expect(page).to have_content(@second_student.proper_name)
    end

    it 'displays empty group report messages', js: true, skip: 'Fails because we cannot close an open print preview window' do
      visit "/reports/groups/#{@empty_group.id}"

      expect(page).to have_content("Group Report - #{@empty_group.group_name}")
      expect(page).to have_content('There are no students in this group')
      expect(page).to have_content('There is no data for this group yet')
    end
  end
end
