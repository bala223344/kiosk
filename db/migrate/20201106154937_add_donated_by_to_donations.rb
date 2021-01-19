class AddDonatedByToDonations < ActiveRecord::Migration[5.0]
  def change
    add_column :donations, :donated_by, :integer
  end
end
