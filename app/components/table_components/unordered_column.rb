class TableComponents::UnorderedColumn < TableComponents::Column
  def initialize(column:)
    @column_name = column[:column_name]
    @numeric = column[:numeric]
    @column_span = column[:column_span]
  end
end
