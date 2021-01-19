class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action  :configure_permitted_parameters, if: :devise_controller?

  layout :set_layout
  def set_layout
     if current_user
       'dashboard'
     else
       'auth'
     end
  end

  def new
    # Override Devise default behaviour and create a profile as well
    build_resource({})
    resource.build_kiosk
    respond_with resource
 end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:email, :password, :first_name, :last_name) }
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:email, :password, :password_confirmation, :current_password, :first_name, :last_name, :phone, kiosk_attributes: [:title,:amount, :inv_num, :inv_desc]) }
 end



end
