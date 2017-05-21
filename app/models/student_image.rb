# frozen_string_literal: true

class StudentImage < ApplicationRecord
  belongs_to :student
  mount_uploader :image, StudentImageUploader

  validates :image, presence: true
end
