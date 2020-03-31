class RemoveSlugFromChurches < ActiveRecord::Migration
  def change
    remove_column :churches, :slug, :string
  end
end
