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
  end
end
