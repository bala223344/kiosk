class AddLast4ToDonations < ActiveRecord::Migration[5.2]
  def change
    add_column :donations, :last4, :string
  end
end
