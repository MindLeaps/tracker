require 'rails_helper'

RSpec.describe 'User interacts with Groups' do
  include_context 'login_with_global_admin'

  describe 'Group Index' do
    groups = []
    before :each do
      groups = create_list :group, 3
      create_list :enrolled_student, 3, organization: groups[0].chapter.organization, groups: [groups[0]]
      students_with_deleted = create_list :enrolled_student, 3, organization: groups[1].chapter.organization, groups: [groups[1]]
      students_with_deleted[2].deleted_at = Time.zone.now
      students_with_deleted[2].save
    end

    it 'displays a list of groups with counts of undeleted students' do
      visit 'groups'
      expect(page).to have_content groups[0].group_name
      expect(page).to have_content groups[1].group_name
      expect(page).to have_content groups[2].group_name

      expect(page.all('.group-row > a:first-child > div:nth-child(5)').map(&:text).sort).to eq %w[3 2 0].sort
    end
  end

  describe 'Group creation' do
    before :each do
      @chapter = create :chapter, chapter_name: 'Chapter One'
    end

    it 'creates a new group', js: true do
      visit '/groups'
      click_link 'Add Group'
      fill_in 'Group name', with: 'Feature Test Group'
      select 'Chapter One', from: 'group_chapter_id'
      fill_in 'group_mlid', with: 'g0'
      click_button 'Create'

      expect(page).to have_content 'Group Added'
      expect(page).to have_content 'Group "Feature Test Group" added.'
    end

    it 'renders error flash when submitted form is incomplete' do
      visit '/groups'
      click_link 'Add Group'
      fill_in 'Group name', with: 'Feature Test Group'
      select 'Chapter One', from: 'group_chapter_id'
      click_button 'Create'

      expect(page).to have_content 'Group Invalid'
      expect(page).to have_content 'Please fix the errors in the form'
    end
  end

  describe 'Group editing' do
    before :each do
      @chapter1 = create :chapter, chapter_name: 'Old Chapter'
      @chapter2 = create :chapter, chapter_name: 'New Chapter', organization: @chapter1.organization
      @group = create :group, group_name: 'Test Group', chapter: @chapter1
      create_list :enrolled_student, 3, organization: @group.chapter.organization, groups: [@group]
    end

    it 'edits the name and chapter of an existing group' do
      visit '/groups'
      click_link 'Test Group'
      click_link 'Edit Group'
      fill_in 'Group name', with: ''
      click_button 'Update'
      expect(page).to have_content 'Group Invalid'
      fill_in 'Group name', with: 'Edited Group'
      select 'New Chapter', from: 'group_chapter_id'
      click_button 'Update'

      expect(page).to have_content 'Group "Edited Group" updated.'
      expect(page).to have_content 'Edited Group'
      expect(page).to have_content 'New Chapter'
    end
  end

  describe 'Group deleting and undeleting' do
    before :each do
      @group = create :group, group_name: 'About to be Deleted'
      @deleted_group = create :group, deleted_at: Time.zone.now, group_name: 'Already Deleted'
      @students = create_list :enrolled_student, 3, organization: @group.chapter.organization, groups: [@group]
    end

    it 'marks the group as deleted' do
      visit '/groups'
      click_link 'About to be Deleted'
      click_button 'Delete Group'

      expect(page).to have_content 'Group "About to be Deleted" deleted.'
      expect(@group.reload.deleted_at).to be_within(1.second).of Time.zone.now

      click_button 'Undo'

      expect(page).to have_content 'Group "About to be Deleted" restored.'
      expect(@group.reload.deleted_at).to be_nil
    end

    it 'restores an already deleted group' do
      visit "/groups/#{@deleted_group.id}"
      click_button 'Restore Deleted Group'
      visit '/groups'
      expect(page).to have_content 'Already Deleted'
      expect(@deleted_group.reload.deleted_at).to be_nil
    end
  end

  describe 'Group searching and filtering', js: true do
    before :each do
      @group1 = create :group, group_name: 'Abisamol'
      @group2 = create :group, group_name: 'Abisouena'
      @group4 = create :group, group_name: 'Abilatava', deleted_at: Time.zone.now
      @group3 = create :group, group_name: 'Milatava'
    end

    it 'searches different groups' do
      visit '/groups'
      expect(page).to have_selector('.group-row', count: 3)
      click_link_compat 'Show Deleted'
      expect(page).to have_selector('.group-row', count: 4)
      find('#search-field').send_keys('Abi', :enter)
      expect(page).to have_selector('.group-row', count: 3)
      expect(page).to have_content 'Abisamol'
      expect(page).to have_content 'Abisouena'
      expect(page).to have_content 'Abilatava'
      expect(page).to have_field('search-field', with: 'Abi')
      click_link_compat 'Show Deleted'
      expect(page).to have_selector('.group-row', count: 2)
      expect(page).to have_content 'Abisamol'
      expect(page).to have_content 'Abisouena'
    end
  end

  describe 'Group reporting', js: true do
    before :each do
      @group = create :group, group_name: 'Report Group'
      @empty_group = create :group, group_name: 'Empty Group'
      @student = create :graded_student, organization: @group.chapter.organization, groups: [@group], grades: { 'Memorization' => [3, 4, 5, 6, 7], 'Grit' => [2, 3, 2, 4, 5] }
    end

    it 'goes to the group report page' do
      visit "/groups/#{@group.id}"
      report_window = window_opened_by do
        click_link 'Generate Report'
      end

      within_window report_window do
        expect(page).to have_content "Group Report - #{@group.group_name}"
      end
    end

    it 'does not show generate report if empty' do
      visit "/groups/#{@empty_group.id}"

      expect(page).to_not have_content 'Generate Report'
    end

    it 'cannot export students if empty' do
      visit "/groups/#{@empty_group.id}"

      expect(page).to_not have_content 'Export Students'
    end
  end

  describe 'Group enrollments', js: true do
    before :each do
      @group = create :group
      @other_group = create :group
      @unenrolled_students = create_list :student, 2, organization: @group.chapter.organization
    end

    it 'enrolls students with no active enrollments' do
      visit "/groups/#{@group.id}"
      click_link 'Enroll Students'

      within('#modal') do
        expect(page).to have_content 'FIRST NAME'
        expect(page).to have_content 'LAST NAME'
        expect(page).to have_content 'ENROLL'
        expect(page).to have_content 'ENROLLED SINCE'

        all('input[id="students__to_enroll"]').each(&:check)
        all('input[id="students__enrollment_start_date"]').each { |df| df.fill_in with: 2.days.ago.to_date.to_s }
        click_button 'Confirm'
      end

      expect(page).to have_content @unenrolled_students.first.first_name
      expect(page).to have_content @unenrolled_students.last.first_name
      expect(@group.reload.students.count).to eql 2
      @unenrolled_students.each do |student|
        student.reload
        expect(student.enrollments.count).to eql 1
        expect(student.enrollments.first.active_since.to_date.to_s).to eql 2.days.ago.to_date.to_s
      end
    end

    it 'gets message when there are no students which can be enrolled' do
      visit "/groups/#{@other_group.id}"
      click_link 'Enroll Students'

      within('#modal') do
        expect(page).to have_content 'No students to be enrolled'
      end
    end

    it 'alerts if the group has a student with grades before their enrollment and corrects the enrollment' do
      group = create :group
      student = create :student, organization: group.chapter.organization, groups: [group]
      enrollment = create :enrollment, student: student, group: group, active_since: 1.day.ago
      enrolled_since_date_formatted = enrollment.active_since.strftime('%Y-%m-%d')
      lesson = create :lesson, group: group, date: 2.days.ago
      lesson_date_formatted = lesson.date.strftime('%Y-%m-%d')
      create :grade, lesson: lesson, student: student

      visit "/groups/#{group.id}"

      expect(page).to have_content 'Students graded before enrollment'
      expect(page).to have_content 'Some students have grades prior their enrollment, please review them below'
      expect(page).to have_content 'Update Enrollment'
      expect(page).to have_selector('span.group > .tooltip', visible: :all, text: "Student graded outside of enrollment. Enrolled since \"#{enrolled_since_date_formatted}\" but has grades for \"#{lesson_date_formatted}\"")

      click_button 'Update Enrollment'

      expect(page).to have_content 'Enrollment Updated'
      expect(page).to have_content "Successfully updated enrollment for student \"#{student.proper_name}\""
      expect(enrollment.reload.active_since.to_date).to eql lesson.date
    end
  end
end
