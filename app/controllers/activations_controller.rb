class ActivationsController < ApplicationController
  def new

    #logger.info params.inspect

    #logger.info response.inspect

     @activation = Activation.new
  end

  def create
     @activation = Activation.new(activation_params)
     if @activation.save
       ActivationMailer.activation_email(@activation).deliver

       render "success"
     end
  end

  private
  def activation_params
    params.require(:activation).permit(:title, :name, :phone, :email)
  end
end
