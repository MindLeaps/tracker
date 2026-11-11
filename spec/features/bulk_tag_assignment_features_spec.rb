require 'rails_helper'

RSpec.describe 'User interacts with bulk tag assignment' do
  include_context 'login_with_global_admin'

  before :each do
    @org = create :organization
    @tag_one = create :tag, tag_name: 'Bulk Tag One', organization: @org
    @tag_two = create :tag, tag_name: 'Bulk Tag Two', organization: @org
    @first_student = create :student, organization: @org, first_name: 'Bulka', last_name: 'Studentova'
    @second_student = create :student, organization: @org, first_name: 'Bulkette', last_name: 'Studentovna'
  end

  it 'assigns tags to the selected students from a dedicated page', js: true do
    visit '/students'
    click_link 'Assign Tags'

    expect(page).to have_current_path(bulk_tag_assignment_students_path)

    toggle_button = find('button[data-action="click->multiselect#toggleMenu"]')
    toggle_button.click
    find('[data-multiselect-target="option"]', text: @tag_one.tag_name).click
    toggle_button.click

    within(:xpath, ".//div[contains(@class, 'student-row') and contains(., 'Bulka')]") do
      find('input[type="checkbox"]').check
    end

    click_button 'Confirm'

    expect(page).to have_content 'Tags Assigned'
    expect(page).to have_content "Successfully assigned tags \"#{@tag_one.tag_name}\" to 1 students."

    expect(@first_student.reload.tags).to include @tag_one
    expect(@second_student.reload.tags).not_to include @tag_one
  end

  it 'shows a failure message when confirming without selecting a tag', js: true do
    visit '/students'
    click_link 'Assign Tags'

    within(:xpath, ".//div[contains(@class, 'student-row') and contains(., 'Bulka')]") do
      find('input[type="checkbox"]').check
    end

    click_button 'Confirm'

    expect(page).to have_content 'No Tags Selected'
    expect(@first_student.reload.tags).not_to include @tag_one
  end

  it 'shows a message when there are no students to tag' do
    Student.find_each { |student| student.update!(deleted_at: Time.zone.now) }

    visit '/students'
    click_link 'Assign Tags'

    expect(page).to have_content 'No Students found'
  end
end
