class CreateOrganizationSummaries < ActiveRecord::Migration[5.2]
  def change
    create_view :organization_summaries
  end
end
