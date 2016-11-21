# frozen_string_literal: true
class StudentImage < ApplicationRecord
  belongs_to :student
  mount_uploader :filename, StudentImageUploader

  validates :filename, presence: true
end
