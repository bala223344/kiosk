class Activation < ActiveRecord::Base
  validates :title, presence: true
  validates :name, presence: true
  validates :phone, presence: true
  
end
