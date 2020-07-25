class AddSchargeToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :scharge_percent, :decimal , default: 3.5
  end
end
