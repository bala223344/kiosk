class AddExtraToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :donation_form_title, :string
    add_column :users, :stripe_pub_key, :string
    add_column :users, :secret_key, :string
  end
end
