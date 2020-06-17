# frozen_string_literal: true

module Helpers
  def test_image_path
    Rails.root.join('spec/images/student_image.png')
  end

  def invalid_image_path
    Rails.root.join('spec/images/invalid_image.txt')
  end

  def test_image
    Rack::Test::UploadedFile.new test_image_path
  end

  def invalid_image
    Rack::Test::UploadedFile.new invalid_image_path
  end
end
