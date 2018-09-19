# frozen_string_literal: true

# rubocop:disable Rails/ApplicationRecord
class StudentLessonSummary < ActiveRecord::Base
  def readonly?
    true
  end
end
# rubocop:enable Rails/ApplicationRecord
