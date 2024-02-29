class TableComponents::GradeDescriptorRow < TableComponents::BaseRow
  def self.columns
    [
      { order_key: :mark, column_name: I18n.t(:mark), numeric: true },
      { order_key: :grade_description, column_name: I18n.t(:grade_description) }
    ]
  end
end
