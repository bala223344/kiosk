class ChangeChurchIdToKioskId < ActiveRecord::Migration
  def change
    rename_column :donations, :church_id, :kiosk_id
  end
end
