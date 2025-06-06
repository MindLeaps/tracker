require 'rails_helper'

RSpec.describe 'User interacts with lessons' do
  context 'As a global administrator' do
    include_context 'login_with_global_admin'

    it 'creates a lesson' do
      create :group, group_name: 'Lesson Group'
      create :subject, subject_name: 'Feature Testing I'

      visit '/'
      click_link 'Lessons'
      click_link 'Add Lesson'

      select 'Lesson Group', from: 'lesson_group_id'
      select 'Feature Testing I', from: 'lesson_subject_id'
      click_button 'Create'

      expect(page).to have_content 'Lesson Added'
    end

    it 'lists all existing lessons' do
      sub = create :subject, subject_name: 'Feature Testing II'
      group = create :group
      create :enrolled_student, organization: group.chapter.organization, groups: [group]

      create(:lesson, subject: sub, group:)
      create(:lesson, subject: sub, group:)

      visit '/'
      click_link 'Lessons'
      expect(page).to have_css 'a.table-row-wrapper', count: 2
      expect(page).to have_content 'Feature Testing II'
    end

    it 'shows a specific lesson', js: true do
      group = create :group, group_name: 'Lesson Feature Test Group'
      create :enrolled_student, organization: group.chapter.organization, groups: [group], first_name: 'Marinko', last_name: 'Marinkovic'
      create :enrolled_student, organization: group.chapter.organization, groups: [group], first_name: 'Ivan', last_name: 'Ivankovic'
      create :enrolled_student, organization: group.chapter.organization, groups: [group], first_name: 'Deleted', last_name: 'Deletovic', deleted_at: Time.zone.now
      sub = create :subject, subject_name: 'Feature Testing III'
      create :skill_in_subject, subject: sub
      create(:lesson, subject: sub, group:)

      visit '/'
      click_link 'Lessons'
      find('div.table-cell', match: :first).click

      expect(page).to have_content 'Lesson Feature Test Group'
      expect(page).to have_content 'Students'
      expect(page).to have_content 'Marinko'
      expect(page).to have_content 'Ivan'
      expect(page).not_to have_content 'Deletovic'
    end

    describe 'grading' do
      let(:group) { create :group, group_name: 'Lesson Feature Test Group' }
      let(:subject) { create :subject, subject_name: 'Feature Testing III' }

      before :each do
        create :enrolled_student, organization: group.chapter.organization, groups: [group], first_name: 'Graden', last_name: 'Gradanovic'
        skill1 = create(:skill_in_subject, skill_name: 'Featuring', subject:)
        skill2 = create(:skill_in_subject, skill_name: 'Testing', subject:)

        create :grade_descriptor, mark: 1, grade_description: 'Mark One For Skill One', skill: skill1
        create :grade_descriptor, mark: 2, grade_description: 'Mark Two For Skill One', skill: skill1
        create :grade_descriptor, mark: 1, grade_description: 'Mark One For Skill Two', skill: skill2
        create :grade_descriptor, mark: 2, grade_description: 'Mark Two For Skill Two', skill: skill2

        @lesson = create :lesson, subject:, group:
      end

      it 'shows students grades in specific lesson', js: true do
        visit "/lessons/#{@lesson.id}"
        find('div.table-cell', text: 'Graden', match: :first).click

        expect(page).to have_content 'Graden'
        expect(page).to have_content 'Featuring'
        expect(page).to have_content 'Testing'
      end

      it 'grades a student', js: true do
        visit "/lessons/#{@lesson.id}"
        find('div.table-cell', text: 'Graden', match: :first).click

        select '2 - Mark Two For Skill One', from: 'Featuring'
        select '1 - Mark One For Skill Two', from: 'Testing'

        click_button 'Save Student Grades'

        expect(page).to have_content 'Student graded.'
        expect(page).to have_content '2 / 2'
        expect(page).to have_content '1.5'
      end
    end
  end
end
