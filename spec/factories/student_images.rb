# frozen_string_literal: true

FactoryGirl.define do
  factory :student_image do
    student { create :student }
    image { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'images', 'student_image.png')) }
  end
end
