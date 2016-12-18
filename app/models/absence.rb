# frozen_string_literal: true
class Absence < ApplicationRecord
  belongs_to :student
  belongs_to :lesson
end
