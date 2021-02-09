# frozen_string_literal: true

class UpdateChapterSummariesToVersion2 < ActiveRecord::Migration[6.0]
  def change
    update_view :chapter_summaries, version: 2, revert_to_version: 1
  end
end
