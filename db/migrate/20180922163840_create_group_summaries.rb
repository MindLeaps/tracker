class CreateGroupSummaries < ActiveRecord::Migration[5.2]
  def change
    create_view :group_summaries
  end
end
