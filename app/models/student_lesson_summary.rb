# frozen_string_literal: true

class StudentLessonSummary < ApplicationRecord
  # Alias for table_order scope of Application record. This is needed because has_scope does not allow for 2 scopes with the same name
  singleton_class.send(:alias_method, :table_order_lesson_students, :table_order)

  def readonly?
    true
  end
end
