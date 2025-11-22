class TableComponents::OrderedColumn < TableComponents::Column
  def initialize(column:, order_scope_name:)
    @column_name = column[:column_name]
    @order_key = column[:order_key]
    @numeric = column[:numeric]
    @order_scope_name = order_scope_name
  end
end
