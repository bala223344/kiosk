class AddMerchantEndPointToUsers < ActiveRecord::Migration
  def change
    add_column :users, :merchant_end_point, :string
  end
end
