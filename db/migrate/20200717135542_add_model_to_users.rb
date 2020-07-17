class AddModelToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :model, :string
  end
end
