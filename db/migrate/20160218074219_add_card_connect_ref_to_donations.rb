class AddCardConnectRefToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :cardconnectref, :string
  end
end
