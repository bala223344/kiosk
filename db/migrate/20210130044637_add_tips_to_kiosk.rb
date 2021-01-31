class AddTipsToKiosk < ActiveRecord::Migration[5.2]
  def change
    add_column :kiosks, :tips, :boolean
  end
end
