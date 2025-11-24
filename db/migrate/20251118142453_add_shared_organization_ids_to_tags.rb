class AddSharedOrganizationIdsToTags < ActiveRecord::Migration[7.2]
  def change
    add_column :tags, :shared_organization_ids, :bigint, array: true, default: []
  end
end
