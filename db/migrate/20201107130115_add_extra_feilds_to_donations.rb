class AddExtraFeildsToDonations < ActiveRecord::Migration[5.0]
  def change
    add_column :donations, :card_type, :string
    add_column :donations, :gateway_fee, :decimal
    add_column :donations, :tx_status, :string

  end
end
