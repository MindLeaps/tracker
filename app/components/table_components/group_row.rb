# frozen_string_literal: true

class TableComponents::GroupRow < ViewComponent::Base
  with_collection_parameter :group

  def before_render
    @group_path = group_path @group
  end

  def initialize(group:, group_counter:, pagy:)
    @group = group
    @group_counter = group_counter
    @pagy = pagy
  end

  def shaded?
    @group_counter.odd?
  end

  def can_update?
    helpers.policy(@group).update?
  end

  def self.columns
    [
      { column_name: '#' },
      { order_key: :full_mlid, column_name: I18n.t(:mlid), numeric: true },
      { order_key: :group_name, column_name: I18n.t(:group_name) },
      { order_key: :chapter_name, column_name: I18n.t(:chapter_organization) },
      { order_key: :student_count, column_name: I18n.t(:number_of_students), numeric: true },
      { column_name: I18n.t(:actions) }
    ]
  end
end
