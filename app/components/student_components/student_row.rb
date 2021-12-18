# frozen_string_literal: true

class StudentComponents::StudentRow < ViewComponent::Base
  delegate :student_group_name, :policy, to: :helpers
  with_collection_parameter :student

  def before_render
    @student_show = student_path @student
    @student_group_name = student_group_name(@student)
  end

  def initialize(student:, student_counter:, pagy:)
    @student = student
    @student_counter = student_counter
    @pagy = pagy
  end

  def render_actions
    return '' unless policy(@student).update?

    "<a id=\"edit-button-#{@student_counter}\" class=\"mdl-button mdl-js-button mdl-button--icon table-action-icon\" href=\"#{@path}\">#{image_tag 'edit.svg'}</a>
    <div class=\"mdl-tooltip\" data-mdl-for=\"edit-button-#{@student_counter}\">#{@tooltip_content}</div>"
  end
end
