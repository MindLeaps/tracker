# frozen_string_literal: true

class StudentComponents::StudentTable < ViewComponent::Base
  delegate :excluding_deleted?, :show_deleted_url, :student_group_name, :policy, to: :helpers

  def initialize(student_rows:, pagy:)
    @students = student_rows
    @pagy = pagy
  end

  # rubocop:disable Metrics/MethodLength
  def columns
    [
      { column_name: '#' },
      { order_key: :full_mlid, column_name: t(:mlid), numeric: true },
      { order_key: :last_name, column_name: t(:last_name) },
      { order_key: :first_name, column_name: t(:first_name) },
      { order_key: :gender, column_name: t(:gender) },
      { order_key: :dob, column_name: t(:date_of_birth), numeric: true },
      { column_name: t(:tags) },
      { order_key: :group_name, column_name: t(:group) },
      { column_name: t(:actions) }
    ]
  end
  # rubocop:enable Metrics/MethodLength
end
