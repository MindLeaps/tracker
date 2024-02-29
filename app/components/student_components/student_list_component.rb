class StudentComponents::StudentListComponent < ViewComponent::Base
  delegate :student_group_name, to: :helpers

  def initialize(student_rows:, pagy:)
    @student_rows = student_rows
    @pagy = pagy
  end
end
