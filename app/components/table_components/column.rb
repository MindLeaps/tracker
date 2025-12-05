class TableComponents::Column < ViewComponent::Base
  delegate :order_parameters, :order_icon, :order_for, to: :helpers
  with_collection_parameter :column

  def initialize(column:, order_scope_name:)
    @column_name = column[:column_name]
    @order_key = column[:order_key]
    @numeric = column[:numeric] || false
    @order_scope_name = order_scope_name

    raise ArgumentError, "Column has to have :column_name. Column: #{column}" unless @column_name
  end

  def call
    return render TableComponents::OrderedColumn.new(column: { column_name: @column_name, order_key: @order_key, numeric: @numeric }, order_scope_name: @order_scope_name) if @order_key

    render TableComponents::UnorderedColumn.new(column: { column_name: @column_name, numeric: @numeric })
  end
end
