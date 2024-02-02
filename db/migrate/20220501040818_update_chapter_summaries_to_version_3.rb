# frozen_string_literal: true

class UpdateChapterSummariesToVersion3 < ActiveRecord::Migration[7.0]
  def change
    update_view :chapter_summaries, version: 3, revert_to_version: 2
  end
end
