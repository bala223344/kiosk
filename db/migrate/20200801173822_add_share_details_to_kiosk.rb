class AddShareDetailsToKiosk < ActiveRecord::Migration[5.0]
  def change
    add_column :kiosks, :amount, :decimal
    add_column :kiosks, :inv_num, :string
    add_column :kiosks, :inv_desc, :string
  end
end
