class AddEmpToDonations < ActiveRecord::Migration[5.2]
  def change
    add_column :donations, :emp, :string, :null => true 
    add_column :donations, :tip_amt, :decimal, :null => true 
  end
end
