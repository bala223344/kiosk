class AddCompanyToDonations < ActiveRecord::Migration[5.2]
  def change
    add_column :donations, :company, :string
  end
end
