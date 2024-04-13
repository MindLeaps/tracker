class UpdateSubjectSummariesToVersion2 < ActiveRecord::Migration[7.0]
  def change
    replace_view :subject_summaries, version: 2, revert_to_version: 1
  end
end
