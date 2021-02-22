class ContactlessController < BaseController

  layout "contactless"

  def show
    if (current_user && current_user.kiosk && current_user.kiosk.id)
      @kiosk = current_user.kiosk
    else
      @kiosk = nil
    end


  end


  def terminalsetup


    hpp = current_user.kiosk.id
    emp = params[:emp]
    phone = params[:phone]
    link = "https://mobile.paynow.io/?hpp=#{hpp}&emp=#{emp}&sms=#{phone}"
#    your_hosted_yourls_address = mobilepay.link
#    your_hosted_yourls_api_key = 75d4341c63




    if params[:sms] == "true"

#      require 'yourls'

#      yourls = Yourls.new(your_hosted_yourls_address, your_hosted_yourls_api_key)
#      yourls.shorten('http://www.google.com')

      sms_number = "+1"+params[:phone]


      body = 'Contactless Terminal Link: ' + link +'

Reply STOP to unsubscribe'

# line break option+enter

      require 'signalwire/sdk'

      @client = Signalwire::REST::Client.new '3fe73725-f958-4c16-ad94-be32579bed82', 'PT23fade6437f208048a783979382fa088bf9fc6bd06e507d5', signalwire_space_url: "startgroup.signalwire.com"


      message = @client.messages.create(
                                  from: '+18884390949',
                                  body: body,
                                  to:  sms_number
                                )
    end

    render :json => {:link =>  link }

  end

  private

  def donation_params
    params.require(:kiosk).permit(donations_attributes: %i[title name email amount cardconnectref inv_num inv_desc donated_by gateway_fee card_type tx_status zip authcode last4 company])
  end

  def profile_params
    params.require(:kiosk).permit(:title, :sms_number, :city, :zip, :state, :staddr, :website, :slogan, :tips )
  end
end
