class CreateActivations < ActiveRecord::Migration
  def change
    create_table :activations do |t|
      t.string :title
      t.string :name
      t.string :phone
      t.string :email

      t.timestamps
    end
  end
end
