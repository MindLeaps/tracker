# frozen_string_literal: true

class TableComponents::Table < ViewComponent::Base
  delegate :excluding_deleted?, :show_deleted_url, :student_group_name, :policy, to: :helpers

  erb_template <<~ERB
    <%= render CommonComponents::PaginationComponent.new(pagy: @pagy) unless @options[:no_pagination] || @pagy.nil? %>
    <div class="overflow-x-scroll bg-white">
      <div class="grid" style="grid-template-columns: repeat(<%= @row_component::columns(**@column_arguments).count %>, minmax(min-content, auto))">
        <%= render TableComponents::Column.with_collection(@row_component::columns(**@column_arguments), order_scope_name: @order_scope_name) %>
        <%= render @row_component.with_collection(@rows, pagy: @pagy, **@row_arguments) %>
      </div>
    </div>
  ERB

  # rubocop:disable Metrics/ParameterLists
  def initialize(row_component:, rows:, column_arguments: {}, row_arguments: {}, order_scope_name: :table_order, pagy: nil, options: {})
    @row_component = row_component
    @rows = rows
    @pagy = pagy
    @column_arguments = column_arguments
    @row_arguments = row_arguments
    @order_scope_name = order_scope_name
    @options = options
  end
  # rubocop:enable Metrics/ParameterLists
end
