class AddSlugToKiosk < ActiveRecord::Migration[5.2]
  def change
    add_column :kiosks, :slug, :string
    add_index :kiosks, [:slug], :unique => true

  end
end
