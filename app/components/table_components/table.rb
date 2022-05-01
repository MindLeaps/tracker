# frozen_string_literal: true

class TableComponents::Table < ViewComponent::Base
  delegate :excluding_deleted?, :show_deleted_url, :student_group_name, :policy, to: :helpers

  def initialize(row_component:, rows:, pagy:)
    @row_component = row_component
    @rows = rows
    @pagy = pagy
  end
end
