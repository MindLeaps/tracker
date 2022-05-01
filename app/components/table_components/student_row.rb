# frozen_string_literal: true

class TableComponents::StudentRow < ViewComponent::Base
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

  def shaded?
    @student_counter.odd?
  end

  def can_update?
    policy(@student).update?
  end

  # rubocop:disable Metrics/MethodLength
  def self.columns
    [
      { column_name: '#' },
      { order_key: :full_mlid, column_name: I18n.t(:mlid), numeric: true },
      { order_key: :last_name, column_name: I18n.t(:last_name) },
      { order_key: :first_name, column_name: I18n.t(:first_name) },
      { order_key: :gender, column_name: I18n.t(:gender) },
      { order_key: :dob, column_name: I18n.t(:date_of_birth), numeric: true },
      { column_name: I18n.t(:tags) },
      { order_key: :group_name, column_name: I18n.t(:group) },
      { column_name: I18n.t(:actions) }
    ]
  end
  # rubocop:enable Metrics/MethodLength
end
