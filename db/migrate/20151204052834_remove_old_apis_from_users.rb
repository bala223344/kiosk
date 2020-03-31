class RemoveOldApisFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :stripe_pub_key, :string
    remove_column :users, :secret_key, :string
  end
end
