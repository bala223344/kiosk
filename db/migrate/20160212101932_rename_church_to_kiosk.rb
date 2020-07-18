class RenameChurchToKiosk < ActiveRecord::Migration
  def change
    rename_table :churches, :kiosks
  end
end
