# frozen_string_literal: true

class LessonTableRow < ApplicationRecord
  belongs_to :group
  def readonly?
    true
  end
end
