class UsersController < ApplicationController
  before_action  :authenticate_user!

  def edit
    @user = current_user
  end

  def delete_stripe
    @user = User.find(current_user.id)
    @user.update_attributes({
                              provider: nil,
                              uid: nil,
                              access_code: nil,
                              publishable_key: nil
                            })
    @user.save
    #  logger.info "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    redirect_to root_path
  end


  def update
    @user = User.find(current_user.id)
    if @user.update(user_profile_params)
     redirect_to edit_user_path(current_user)
    else
      redirect_to edit_user_path(current_user)
    end
  end


  def update_password
    @user = User.find(current_user.id)
    user_params[:password_changed_at] = Time.new
    if @user.update_with_password(user_params)

      # Sign in the user by passing validation in case their password changed
      sign_in @user, bypass: true
      render 'success'
    else
      render 'edit'
    end
  end

  private

  def user_params
    # NOTE: Using `strong_parameters` gem
    params.require(:user).permit(:password, :password_confirmation, :current_password)
  end


  def user_profile_params
    # NOTE: Using `strong_parameters` gem
    params.require(:user).permit(:email, :fname, :lname, :phone, :tz)
  end
end
