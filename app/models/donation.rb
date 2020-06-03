class Donation < ApplicationRecord
 belongs_to :kiosk, :class_name => 'Kiosk', :foreign_key => 'kiosk_id'

end
