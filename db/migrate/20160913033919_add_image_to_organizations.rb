class AddImageToOrganizations < ActiveRecord::Migration[5.0]
  def change
    add_column :organizations, :image, :string, default: 'https://placeholdit.imgix.net/~text?txtsize=23&txt=200%C3%97200&w=200&h=200'
  end
end
