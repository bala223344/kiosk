class AddSmsNumberToKiosk < ActiveRecord::Migration[5.0]
  def change
    add_column :kiosks, :sms_number, :string
  end
end
