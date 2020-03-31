class AddIndexToChurch < ActiveRecord::Migration
  def change
    add_column :churches, :slug, :string
    add_index :churches, :slug
  end
end
