class UpdateOrganizationSummariesToVersion3 < ActiveRecord::Migration[7.0]
  def change
    replace_view :organization_summaries, version: 3, revert_to_version: 2
  end
end
