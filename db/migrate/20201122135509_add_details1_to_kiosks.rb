class AddDetails1ToKiosks < ActiveRecord::Migration[5.2]
  def change
    add_column :kiosks, :staddr, :string
    add_column :kiosks, :city, :string
    add_column :kiosks, :zip, :string
    add_column :kiosks, :state, :string
    add_column :kiosks, :slogan, :string
    add_column :kiosks, :website, :string
  end
end
