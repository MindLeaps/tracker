# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'User interacts with student images' do
  context 'As a global administrator' do
    include_context 'login_with_admin'

    before :each do
      @student = create :student
      @image1 = create :student_image, student: @student
      @image2 = create :student_image, student: @student
    end

    it 'displays all images belonging to a specific student' do
      visit student_path @student
      click_link 'Images'

      expect(page).to have_selector 'img.student-image', count: 2
    end

    it 'uploads and displays two new student images' do
      visit student_path @student
      click_link 'Images'

      attach_file 'student_image[image][]', [test_image_path, test_image_path]
      click_button 'Upload'

      expect(page).to have_content 'Images successfully uploaded.'
      expect(page).to have_selector 'img.student-image', count: 4
    end

    it 'displays the profile image in the student\'s profile and its thumbnail in the student list' do
      visit student_path @student
      click_link 'Images'

      first('.student-image-card').click_button 'Set as Profile'

      expect(page.current_path).to eq student_path @student
      expect(page).to have_selector 'img.student-profile-image'

      visit students_path

      expect(page).to have_css "img.mini-thumb-profile-image[src='#{@image1.image.mini_thumb.url}']"
    end
  end
end
