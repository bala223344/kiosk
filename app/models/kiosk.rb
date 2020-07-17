class Kiosk < ApplicationRecord
  belongs_to :user, class_name: 'User', foreign_key: 'user_id'
  validates_uniqueness_of :title

  attr_accessor :mail_content, :email, :subject

  has_many :donations

  accepts_nested_attributes_for :donations
end
