require 'rails_helper'

RSpec.describe 'Chapter dashboard', type: :feature do
  it 'opens after login and keeps activity visible without JavaScript while filtering the snapshot' do
    organization = create(:organization)
    chapter = create(:chapter, organization:)
    user = create(:teacher_in, organization:, preferred_chapter: chapter)
    group = create(:group, chapter:)
    other_group = create(:group, chapter:)
    subject = create(:subject, organization:)
    create(:lesson, group:, subject:, date: Date.current)

    login(user)
    expect(page).to have_current_path(dashboard_path)
    expect(page).to have_content("Your week in #{chapter.chapter_name}")
    expect(page).to have_content('Lessons recorded')
    expect(page).to have_link(group.group_name, href: group_path(group))
    select other_group.group_name, from: 'Group'
    select subject.subject_name, from: 'Subject'
    click_button 'Update snapshot'
    expect(page).to have_select('Group', selected: other_group.group_name)
    expect(page).to have_content('Lessons recorded')
    click_link 'Students'
    expect(page).to have_current_path(students_path)
    click_link 'Dashboard'
    expect(page).to have_current_path(dashboard_path)
  end

  it 'shows dated learning evidence and a report link on the chapter dashboard' do
    organization = create(:organization)
    chapter = create(:chapter, organization:)
    user = create(:teacher_in, organization:, preferred_chapter: chapter)
    group = create(:group, chapter:)
    subject = create(:subject, organization:)
    skill = create(:skill_with_descriptors, organization:, subject:)
    student = create(:student, organization:)
    create(:enrollment, student:, group:, active_since: Date.current - 60)
    [6, 4, 3].zip([20, 10, 0]).each do |mark, offset|
      lesson = create(:lesson, group:, subject:, date: Date.current - offset)
      create(:grade, student:, lesson:, grade_descriptor: skill.grade_descriptors.find_by!(mark:))
    end

    login(user)
    expect(page).to have_link(student.proper_name, href: reports_student_path(student))
    expect(page).to have_content(skill.skill_name)
    expect(page).to have_content('Not enough assessments')
    expect(page).to have_content(I18n.l(Date.current - 20, format: :short))
  end
end
