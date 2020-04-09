class AddMerchantDetailsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :merchant_username, :string
    add_column :users, :merchant_password, :string
  end
end
