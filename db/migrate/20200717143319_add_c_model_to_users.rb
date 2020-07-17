class AddCModelToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :cmodel, :string

  end
end
