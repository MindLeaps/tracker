# frozen_string_literal: true

class UpdateGroupSummariesToVersion2 < ActiveRecord::Migration[6.1]
  def change
    update_view :group_summaries, version: 2, revert_to_version: 1
  end
end
