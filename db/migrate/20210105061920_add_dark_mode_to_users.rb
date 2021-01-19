class AddDarkModeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :dark_mode, :boolean
  end
end
