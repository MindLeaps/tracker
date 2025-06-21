require 'rails_helper'

RSpec.describe 'User interacts with enrollments' do
  context 'As a global administrator' do
    include_context 'login_with_global_admin'

    it 'only show students enrolled in the group at the time', js: true do
      chapter = create :chapter
      first_group = create :group, group_name: 'Enrollment Feature Test Group I', chapter: chapter
      second_group = create :group, group_name: 'Enrollment Feature Test Group II', chapter: chapter
      third_group = create :group, group_name: 'Enrollment Feature Test Group III', chapter: chapter

      first_student = create(:student, first_name: 'Marinko', last_name: 'Marinkovic', organization: first_group.chapter.organization)
      second_student = create(:student, first_name: 'Ivan', last_name: 'Ivankovic', organization: first_group.chapter.organization)
      third_student = (create :student, first_name: 'Roberto', last_name: 'Robertovic', organization: second_group.chapter.organization)
      fourth_student = (create :student, first_name: 'Outsider', last_name: 'Outsiderovic', organization: third_group.chapter.organization)
      fifth_student = (create :student, first_name: 'Vladimir', last_name: 'Impalerovic', organization: first_group.chapter.organization)

      [first_student, second_student].each { |s| create :enrollment, student: s, group: first_group, active_since: 1.month.ago }
      create :enrollment, student: third_student, group: second_group, active_since: 1.month.ago
      create :enrollment, student: fourth_student, group: third_group, active_since: 1.day.ago
      create :enrollment, student: fourth_student, group: first_group, active_since: 1.month.ago, inactive_since: 1.day.ago
      create :enrollment, student: fourth_student, group: second_group, active_since: 1.month.ago, inactive_since: 1.day.ago
      create :enrollment, student: fifth_student, group: first_group

      sub = create :subject, subject_name: 'Feature Testing III'
      create :skill_in_subject, subject: sub
      @lesson_one = create(:lesson, subject: sub, group: first_group, date: 1.month.ago)
      @lesson_two = create(:lesson, subject: sub, group: second_group, date: 1.month.ago)
      @lesson_three = create(:lesson, subject: sub, group: third_group, date: 1.day.ago)

      visit "/lessons/#{@lesson_one.id}"
      expect(page).to have_content 'Marinko'
      expect(page).to have_content 'Ivan'
      expect(page).to have_content 'Outsider'
      expect(page).not_to have_content 'Roberto'
      expect(page).not_to have_content 'Vladimir'

      visit "/lessons/#{@lesson_two.id}"
      expect(page).to have_content 'Roberto'
      expect(page).to have_content 'Outsider'
      expect(page).not_to have_content 'Marinko'
      expect(page).not_to have_content 'Ivan'
      expect(page).not_to have_content 'Vladimir'

      visit "/lessons/#{@lesson_three.id}"
      expect(page).to have_content 'Outsider'
      expect(page).not_to have_content 'Marinko'
      expect(page).not_to have_content 'Ivan'
      expect(page).not_to have_content 'Roberto'
      expect(page).not_to have_content 'Vladimir'
    end
  end
end
