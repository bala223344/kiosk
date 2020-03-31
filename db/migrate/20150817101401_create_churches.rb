class CreateChurches < ActiveRecord::Migration
  def change
    create_table :churches do |t|
      t.string :title

      t.timestamps
    end
  end
end
