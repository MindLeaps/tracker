# frozen_string_literal: true
FactoryGirl.define do
  factory :student_image do
    student { create :student }
    filename { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'images', 'student_image.png')) }
  end
end
