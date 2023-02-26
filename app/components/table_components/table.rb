# frozen_string_literal: true

class TableComponents::Table < ViewComponent::Base
  delegate :excluding_deleted?, :show_deleted_url, :student_group_name, :policy, to: :helpers

  # rubocop:disable Metrics/ParameterLists
  def initialize(row_component:, rows:, pagy: nil, column_arguments: {}, row_arguments: {}, order_scope_name: :table_order)
    @row_component = row_component
    @rows = rows
    @pagy = pagy
    @column_arguments = column_arguments
    @row_arguments = row_arguments
    @order_scope_name = order_scope_name
  end
  # rubocop:enable Metrics/ParameterLists
end
