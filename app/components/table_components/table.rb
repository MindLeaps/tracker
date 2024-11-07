class TableComponents::Table < ViewComponent::Base
  delegate :excluding_deleted?, :show_deleted_url, :student_group_name, :policy, to: :helpers
  renders_one :left

  erb_template <<~ERB
    <div class="flex bg-white justify-between items-center px-4 border-b border-gray-200">
      <div class="flex-1">
        <% if left? %>
          <%= left %>
        <% end %>
      </div>
      <%= render CommonComponents::PaginationComponent.new(pagy: @pagy) unless @options[:no_pagination] || @pagy.nil? %>
      </div>
      <div class="overflow-x-scroll bg-white">
        <div id="<%= @options[:turbo_id] %>" class="grid" style="<%= grid_columns %>">
          <%= render TableComponents::Column.with_collection(@row_component::columns(**@column_arguments), order_scope_name: @order_scope_name) %>
          <% if @options[:turbo_id] %> <div id="turbo-separator" class='h-px' style="grid-column: 1/-1;"></div> <% end %>
          <%= render @row_component.with_collection(@rows, pagy: @pagy, **@row_arguments) %>
        </div>
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

  def grid_columns
    "grid-template-columns: repeat(#{@row_component.columns(**@column_arguments).count}, #{@options[:wrap] ? 'minmax(max-content, auto)' : 'auto'})"
  end
end
