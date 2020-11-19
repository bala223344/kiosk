class AddAuthcodeToDonations < ActiveRecord::Migration[5.0]
  def change
    add_column :donations, :authcode, :string
  end
end
