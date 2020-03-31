class AddInvoiceToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :inv_num, :string
    add_column :donations, :inv_desc, :string
  end
end
