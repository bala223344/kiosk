class AddChurchRefToDonations < ActiveRecord::Migration
  def change
    add_reference :donations, :church, index: true
  end
end
