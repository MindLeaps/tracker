# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HtmlController, type: :controller do
  describe 'flash_redirect' do
    it 'saves the redirect path to flash[:redirect]' do
      controller.flash_redirect(students_url)
      expect(flash[:redirect]).to eq students_path
    end

    it 'saves the redirect path including query to flash[:redirect]' do
      controller.flash_redirect('https://test.host/students?param1=something')
      expect(flash[:redirect]).to eq '/students?param1=something'
    end

    it 'does not save the redirect path to flash[:redirect] if the path does not belong to application' do
      controller.flash_redirect('https://other.host/groups')
      expect(flash[:redirect]).to be_nil
    end
  end
end
