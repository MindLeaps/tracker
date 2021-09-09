# frozen_string_literal: true

class Enrollment < ApplicationRecord
  belongs_to :student
  belongs_to :group
end
