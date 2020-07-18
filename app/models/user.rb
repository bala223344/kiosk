class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :trackable, :rememberable, :validatable
  attr_accessor :login, :terms, :current_password
  before_create :build_default_kiosk
  validates :username,
            presence: true,
            uniqueness: {
              case_sensitive: false
            }


 


  has_one :kiosk
  accepts_nested_attributes_for(:kiosk, update_only: true)
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).where(['lower(username) = :value OR lower(email) = :value', { value: login.downcase }]).first
    else
      where(conditions.to_h).first
    end
      end
end

private
def build_default_kiosk
  # build default profile instance. Will use default params.
  # The foreign key to the owning User model is set automatically
  build_kiosk
  true # Always return true in callbacks as the normal 'continue' state
  # Assumes that the default_profile can **always** be created.
  # or
  # Check the validation of the profile. If it is not valid, then
  # return false from the callback. Best to use a before_validation
  # if doing this. View code should check the errors of the child.
  # Or add the child's errors to the User model's error array of the :base
  # error item
end
