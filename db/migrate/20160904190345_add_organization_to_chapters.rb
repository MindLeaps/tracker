class AddOrganizationToChapters < ActiveRecord::Migration[5.0]
  def change
    add_reference :chapters, :organization, index: true
  end
end
