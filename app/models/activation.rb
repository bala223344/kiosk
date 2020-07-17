class Activation < ApplicationRecord
  validates :title, presence: true
  validates :name, presence: true
  validates :phone, presence: true
end
