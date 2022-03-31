# frozen_string_literal: true

class CommonComponents::Column < ViewComponent::Base
  delegate :order_parameters, :order_icon, :order_for, to: :helpers
  with_collection_parameter :column

  def initialize(column:)
    @column_name = column[:column_name]
    @order_key = column[:order_key]
    @numeric = column[:numeric] || false


    raise ArgumentError, "Column has to have :column_name. Column: #{column}" unless @column_name
  end

  def column_class
    @numeric ? 'mdl-data-table__cell' : 'mdl-data-table__cell--non-numeric'
  end




  def call
    return render CommonComponents::OrderedColumn.new(column: { column_name: @column_name, order_key: @order_key, numeric: @numeric }) if @order_key

    render CommonComponents::UnorderedColumn.new(column: { column_name: @column_name, numeric: @numeric })
  end
end

class CommonComponents::OrderedColumn < CommonComponents::Column
  def initialize(column:)
    @column_name = column[:column_name]
    @order_key = column[:order_key]
    @numeric = column[:numeric]
  end
end

class CommonComponents::UnorderedColumn < CommonComponents::Column
  def initialize(column:)
    @column_name = column[:column_name]
    @numeric = column[:numeric]
  end
end
