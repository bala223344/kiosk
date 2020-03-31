class AddMerchIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :merchid, :string
  end
end
