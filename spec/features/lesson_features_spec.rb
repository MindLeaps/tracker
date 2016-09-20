require 'rails_helper'

RSpec.describe 'User interacts with lessons' do
  context 'As a global administrator' do
    include_context 'login_with_admin'

    it 'creates a lesson' do
      create :group, group_name: 'Lesson Group'
      create :subject, subject_name: 'Feature Testing I'

      visit '/'
      click_link 'Lessons'

      select 'Lesson Group', from: 'lesson_group_id'
      select 'Feature Testing I', from: 'lesson_subject_id'
      click_button 'Create'

      expect(page).to have_content 'Lesson successfully created'
    end

    it 'lists all existing lessons' do
      sub = create :subject, subject_name: 'Feature Testing II'
      create :lesson, subject: sub
      create :lesson, subject: sub

      visit '/'
      click_link 'Lessons'

      expect(page).to have_css '.lesson-row', count: 2
      expect(page).to have_content 'Feature Testing II'
    end

    it 'shows a specific lesson' do
      group = create :group, group_name: 'Lesson Feature Test Group'
      create :student, first_name: 'Marinko', last_name: 'Marinkovic', group: group
      create :student, first_name: 'Ivan', last_name: 'Ivankovic', group: group
      sub = create :subject, subject_name: 'Feature Testing III'
      create :lesson, subject: sub, group: group

      visit '/'
      click_link 'Lessons'
      first('.lesson-row-link').click

      expect(page).to have_content 'Lesson Feature Test Group'
      expect(page).to have_content 'Students'
      expect(page).to have_content 'Marinko'
      expect(page).to have_content 'Ivan'
    end

    it 'shows students grades in specific lesson' do
      group = create :group, group_name: 'Lesson Feature Test Group'
      create :student, first_name: 'Graden', last_name: 'Gradanovic', group: group
      sub = create :subject, subject_name: 'Feature Testing III'
      create :skill_in_subject, skill_name: 'Feature Skill I', subject: sub
      create :skill_in_subject, skill_name: 'Feature Skill II', subject: sub
      lesson = create :lesson, subject: sub, group: group

      visit "/lessons/#{lesson.id}"
      click_link 'Graden'

      expect(page).to have_content 'Graden'
      expect(page).to have_content 'Feature Skill I'
      expect(page).to have_content 'Feature Skill II'
    end
  end
end
