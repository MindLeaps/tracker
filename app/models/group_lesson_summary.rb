# frozen_string_literal: true

class GroupLessonSummary < ApplicationRecord
  self.primary_key = :lesson_id
  belongs_to :chapter

  def readonly?
    true
  end
end
