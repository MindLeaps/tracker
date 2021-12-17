# frozen_string_literal: true

class StudentComponents::StudentTable < ViewComponent::Base
  delegate :excluding_deleted?, :show_deleted_url, :student_group_name, :policy, to: :helpers
  attr_reader :pagy, :students

  def initialize
    students = StudentTableRow.includes(:tags, { group: { chapter: :organization } })
    @pagy, @students = yield(students)
  end
end
