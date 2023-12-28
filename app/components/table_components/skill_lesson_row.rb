# frozen_string_literal: true

class TableComponents::SkillLessonRow < TableComponents::BaseRow
  erb_template <<~ERB
      <div class="<%= 'shaded-row' if shaded? %> table-row-wrapper">
      <a href="<%= helpers.skill_path @item.skill_id %>" class="<%= 'shaded-row' if shaded? %> table-row-wrapper">
      <div class="relative px-6 py-3 whitespace-nowrap text-sm font-medium text-gray-600 "><%= @pagy.from + @item_counter %></div>
        <div class="table-cell text-right"><%= @item.skill_name %></div>
        <div class="table-cell "><%= @item.average_mark %></div>
        <div class="table-cell "><%= @item.grade_count %></div>
      </a>
    </div>

  ERB
  def self.columns
    [
      { column_name: '#', numeric: true },
      { order_key: :skill, column_name: I18n.t(:skill) },
      { order_key: :average, column_name: I18n.t(:average), numeric: true },
      { order_key: :grades, column_name: I18n.t(:grades), numeric: true }
    ]
  end
end
