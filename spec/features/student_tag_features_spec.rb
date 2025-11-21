require 'rails_helper'

RSpec.describe 'User interacts with Student Tags' do
  include_context 'login_with_global_admin'

  describe 'Create Tag' do
    before :each do
      @org = create :organization
      @other_organizations = create_list :organization, 2
      @tags = create_list :tag, 3, organization: @org
    end

    it 'navigates to tags, creates a new tag and assigns it to the student', js: true do
      create :student, organization: @org, first_name: 'Taggy', last_name: 'Studenty', gender: 'F'

      visit '/students'
      click_link 'Student Tags'
      click_link 'Add Tag'
      fill_in 'Tag name', with: 'My Test Tag'
      select(@org.organization_name, from: 'Organization')
      find('button', text: 'Select Organizations').click
      find('span', text: @other_organizations[0].organization_name).click

      expect(page).to have_content '1 selected'

      find('input[name="tag[shared]"]').click
      click_button 'Create'

      expect(page).to have_content 'Tag "My Test Tag" added'
      expect(page).to have_content 'My Test Tag'
      expect(page).to have_content @tags[0].tag_name
      expect(page).to have_content @tags[1].tag_name
      expect(page).to have_content @tags[2].tag_name

      find('div.table-cell', text: 'My Test Tag', match: :first).click
      click_link 'Edit Tag'

      fill_in 'Tag name', with: 'My Edited Tag'
      click_button 'Update'

      expect(page).to have_content 'My Edited Tag'

      click_link 'Student Tags'
      expect(page).to have_content 'My Edited Tag'

      visit '/students'
      find('div.table-cell', text: 'Taggy', match: :first).click
      click_link 'Edit Student'
      fill_in 'tag-autocomplete', with: 'My Edited T'
      find('.awesomplete ul li:first-child').click
      click_button 'Update'

      visit '/students'
      click_link 'Student Tags'
      find('div.table-cell', text: 'My Edited Tag', match: :first).click
    end
  end

  describe 'Delete Tag' do
    before :each do
      @org = create :organization
      @chapter = create :chapter, organization: @org
      @group = create :group, chapter: @chapter
      @student = create :enrolled_student, organization: @org, groups: [@group]
      @used_tag = create :tag, tag_name: 'Used Tag', organization: @org
      @unused_tag = create :tag, tag_name: 'Unused Tag', organization: @org
      create :student_tag, student: @student, tag: @used_tag
    end

    it 'visits the used tag and tries to delete it', js: true do
      visit "/student_tags/#{@used_tag.id}"
      click_button 'Delete Tag'

      expect(page).to have_content 'Unable to delete tag'
      expect(page).to have_content 'Tag not deleted because it has students associated with it. Remove it from the students before deleting.'
      expect(Tag.exists?(@used_tag.id)).to be true
    end

    it 'visits the unused tag and deletes it', js: true do
      visit "/student_tags/#{@unused_tag.id}"
      click_button 'Delete Tag'

      expect(page).to have_content 'Tag Deleted'
      expect(page).to have_content 'Tag "Unused Tag" deleted.'
      expect(page).to have_current_path(student_tags_path)
      expect(Tag.exists?(@unused_tag.id)).to be false
    end
  end

  describe 'Tag searching and filtering' do
    before :each do
      @org = create :organization, country: 'Aruba'
      @chapter = create :chapter, organization: @org
      @group = create :group, chapter: @chapter
      @student = create :enrolled_student, organization: @org, groups: [@group]
      @tag = create :tag, tag_name: 'Used Tag', organization: @org
      create :student_tag, student: @student, tag: @tag
    end

    it 'searches tags by country of organization', js: true do
      visit '/student_tags'

      fill_in 'search-field', with: 'Test'

      expect(page).not_to have_content 'Used Tag'

      fill_in 'search-field', with: 'Aruba'

      expect(page).to have_content 'Used Tag'
    end
  end
end
