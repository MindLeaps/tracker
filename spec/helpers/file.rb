# frozen_string_literal: true
module Helpers
  def test_image_path
    File.join(Rails.root, 'spec', 'images', 'student_image.png')
  end

  def test_image
    Rack::Test::UploadedFile.new test_image_path
  end
end
