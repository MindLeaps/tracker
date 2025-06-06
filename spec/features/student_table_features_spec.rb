require 'rails_helper'

RSpec.describe 'User searches and navigates through students table', js: true do
  include_context 'login_with_global_admin'

  context 'without pagination' do
    before :each do
      create :student, first_name: 'Umborato', last_name: 'Aco', mlid: 'ACO', created_at: 1.day.ago
      create :student, first_name: 'Umberto', last_name: 'Eco', mlid: 'ECO', created_at: 2.days.ago
      create :student, first_name: 'Umbdeleto', last_name: 'Del', mlid: 'DEL', deleted_at: Time.zone.now, created_at: 4.days.ago
      create :student, first_name: 'Amberto', last_name: 'Oce', mlid: 'OCE', created_at: 5.days.ago
    end

    it 'displays searched students, including deleted' do
      visit '/students'
      expect(page).to have_selector('div.table-row-wrapper', count: 3)
      click_link_compat 'Show Deleted'
      expect(page).to have_selector('div.table-row-wrapper', count: 4)
      find('#search-field').send_keys('Umb', :enter)
      expect(page).to have_selector('div.table-row-wrapper', count: 3)
      rows = page.all('div.table-row-wrapper')
      expect(rows[0]).to have_content 'Umborato'
      expect(rows[1]).to have_content 'Umberto'
      expect(rows[2]).to have_content 'Umbdeleto'
      expect(page).to have_field('search-field', with: 'Umb')
      click_link_compat 'Show Deleted'
      expect(page).to have_selector('div.table-row-wrapper', count: 2)
      rows = page.all('div.table-row-wrapper')
      expect(rows[0]).to have_content 'Umborato'
      expect(rows[1]).to have_content 'Umberto'
    end
  end

  context 'with pagination' do
    before :each do
      create_list :student, 50
    end

    it 'navigates to the 2nd page and performs the search there' do
      create :student, first_name: 'test_prefix_Umborato', last_name: 'Aco', mlid: 'ACO'
      create :student, first_name: 'test_prefix_Umberto', last_name: 'Eco', mlid: 'ECO'
      create :student, first_name: 'test_prefix_Amberto', last_name: 'Oce', mlid: 'OCE'

      visit '/students'
      expect(page).to have_selector('.student-row', count: 50)
      find('.next-page').click
      expect(page).to have_selector('.student-row', count: 3)
      find('#search-field').send_keys('test_prefix_Amb', :enter)
      expect(page).to have_selector('.student-row', count: 1)
      find('#search-field').send_keys([:backspace] * 15, :enter)
      expect(page).to have_selector('.student-row', count: 50)
      find('.next-page').click
      expect(page).to have_selector('.student-row', count: 3)
    end

    it 'shows deleted, navigates to 2nd page where there are only deleted students and then hides deleted' do
      create :student, first_name: 'test_prefix_Umborato', last_name: 'Aco', mlid: 'ACO', deleted_at: Time.zone.now
      create :student, first_name: 'test_prefix_Umberto', last_name: 'Eco', mlid: 'ECO', deleted_at: Time.zone.now
      create :student, first_name: 'test_prefix_Umbdeleto', last_name: 'Del', mlid: 'DEL', deleted_at: Time.zone.now
      create :student, first_name: 'test_prefix_Amberto', last_name: 'Oce', mlid: 'OCE', deleted_at: Time.zone.now

      visit '/students'
      expect(page).to have_selector('.student-row', count: 50)
      expect(page).to have_selector('.next-page.pointer-events-none')
      click_link_compat('Show Deleted')
      expect(page).not_to have_selector('.next-page.pointer-events-none')
      find('.next-page').click
      expect(page).to have_selector('.student-row', count: 4)
      click_link_compat('Show Deleted')
      expect(page).to have_selector('.student-row', count: 50)
    end
  end

  context 'with filters' do
    describe 'by organization and tag name' do
      before :each do
        @org = create :organization, organization_name: 'First Organization'
        @first_chapter = create :chapter, organization: @org
        @first_group = create :group, chapter: @first_chapter
        @another_org = create :organization, organization_name: 'Second Organization'
        @second_chapter = create :chapter, organization: @another_org
        @second_group = create :group, chapter: @second_chapter
        @first_student = create :enrolled_student, organization: @first_group.chapter.organization, groups: [@first_group], first_name: 'Cicada'
        @second_student = create :enrolled_student, organization: @second_group.chapter.organization, groups: [@second_group], first_name: 'Enchilada'
        @third_student = create :enrolled_student, organization: @second_group.chapter.organization, groups: [@second_group], first_name: 'Quesadilla'
        @shared_tag = create :tag, organization: @another_org, tag_name: 'Shared Tag', shared: true
        @tag = create :tag, organization: @org, tag_name: 'Test Tag', shared: false
        create :student_tag, tag: @shared_tag, student: @first_student
        create :student_tag, tag: @shared_tag, student: @second_student
        create :student_tag, tag: @shared_tag, student: @third_student
        create :student_tag, tag: @tag, student: @first_student
      end

      it 'displays students found by organization name' do
        visit '/students'

        expect(page).to have_selector('div.table-row-wrapper', count: 3)

        fill_in 'search-field', with: 'Second Organization'

        expect(page).to have_selector('div.table-row-wrapper', count: 2)
        expect(page).not_to have_content 'Cicada'
        expect(page).to have_content 'Enchilada'
        expect(page).to have_content 'Quesadilla'
      end

      it 'displays students found by tag name' do
        visit '/students'

        expect(page).to have_selector('div.table-row-wrapper', count: 3)

        fill_in 'search-field', with: 'Test Tag'

        expect(page).to have_selector('div.table-row-wrapper', count: 1)
        expect(page).to have_content 'Cicada'
        expect(page).not_to have_content 'Enchilada'
        expect(page).not_to have_content 'Quesadilla'
      end

      it 'displays students found by both organization and tag name' do
        visit '/students'

        expect(page).to have_selector('div.table-row-wrapper', count: 3)

        fill_in 'search-field', with: 'Shared Tag Second Organization'

        expect(page).to have_selector('div.table-row-wrapper', count: 2)
        expect(page).not_to have_content 'Cicada'
        expect(page).to have_content 'Enchilada'
        expect(page).to have_content 'Quesadilla'

        fill_in 'search-field', with: 'Теst Tag Second Organization'

        expect(page).to have_selector('div.table-row-wrapper', count: 0)
        expect(page).not_to have_content 'Cicada'
        expect(page).not_to have_content 'Enchilada'
        expect(page).not_to have_content 'Quesadilla'
      end
    end
  end
end
