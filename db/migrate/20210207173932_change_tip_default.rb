class ChangeTipDefault < ActiveRecord::Migration[5.2]
  def change
    change_column :donations, :tip_amt, :decimal,  :default => 0

  end
end
