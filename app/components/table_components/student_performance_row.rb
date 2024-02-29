class TableComponents::StudentPerformanceRow < TableComponents::BaseRow
  def initialize(item:, item_counter:, pagy:, skill_ids:)
    super(item:, item_counter:, pagy:)
    @skill_ids = skill_ids
  end

  def self.columns(skills:)
    [
      { column_name: '#', numeric: true },
      { order_key: :date, column_name: I18n.t('date.date'), numeric: true },
      { order_key: :average_mark, column_name: I18n.t(:average_grade), numeric: true }
    ].concat(skills.map { |skill| { order_key: "skill_marks -> '#{skill.id}' ->> 'mark'", column_name: skill.skill_name, numeric: true } })
  end
end
