class PayController < BaseController

  

  def show


    #get from db params[:id]

    # @kiosk = Kiosk.find(params[:id])
    # @user = User.find(@kiosk.user_id)

     render :json => {:donations => "sdfsdffyy"}


  end


end
