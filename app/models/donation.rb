class Donation < ActiveRecord::Base
 belongs_to :kiosk, :class_name => 'Kiosk', :foreign_key => 'kiosk_id'

end
