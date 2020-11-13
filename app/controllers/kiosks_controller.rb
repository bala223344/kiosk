class KiosksController < ApplicationController
  def show
    

    # require 'signalwire/sdk'


    # @client = Signalwire::REST::Client.new '3fe73725-f958-4c16-ad94-be32579bed82', 'PT23fade6437f208048a783979382fa088bf9fc6bd06e507d5', signalwire_space_url: "startgroup.signalwire.com"



    # message = @client.messages.create(
    #   from: '+14158140047',
    #   body: "wat good",
    #   to: '+917418414091'
    # )


    @kiosk = Kiosk.find(params[:id])
    @user = User.find(@kiosk.user_id)

  end

  def new
    @kiosk = Project.new

  end

  def update
    id = params[:id]
    kiosk = Kiosk.find(id)

    number = params[:number]
    cvc = params[:cvc]
    exp_mn = params[:exp_mn].to_s
    exp_yr = params[:exp_yr].to_s
    amount = params[:kiosk][:donations_attributes]['0'][:amount]
    fee = params[:kiosk][:donations_attributes]['0'][:fee_amt]

    inv_num = params[:kiosk][:donations_attributes]['0'][:inv_num]
    inv_desc = params[:kiosk][:donations_attributes]['0'][:inv_desc]
    name = params[:kiosk][:donations_attributes]['0'][:name]
    email = params[:kiosk][:donations_attributes]['0'][:email]


    begin

        
        #if model is surcharge fee is only for credit card..determin if it is not a CC
       if kiosk.user.cmodel == 'surcharge'
        first8dig = number.to_s[0..7]
        ccres = RestClient.get("https://lookup.binlist.net/#{first8dig}", { 'Accept-Version' => '3'})
        ccbody = JSON.parse(ccres.body)
        #no CC..no fee
        if ccbody["type"] != "credit"

          fee = 0
        end 
      end 
      amount = amount.to_f + fee.to_f

      if amount < 0
        @response = { 'errors' => 'Invalid amount' }
      else
        cparams = { 'merchid' => kiosk.user.merchid, 'amount' => amount, 'expiry' => exp_mn + exp_yr, 'account' => number, 'currency' => 'USD', 'name' => name, 'ecomind' => 'E', 'cvv2' => cvc }

        cred_combo = "#{kiosk.user.merchant_username}:#{kiosk.user.merchant_password}"
        #just AUTH  
        res = RestClient.post("#{kiosk.user.merchant_end_point}/cardconnect/rest/auth", cparams.to_json, { 'Authorization' => 'Basic ' + Base64.strict_encode64(cred_combo), :content_type => 'application/json' })



        response = JSON.parse(res.body)

        
       
        if response['respstat'] == 'A'
          string_email = ''
          string_email = 'from ' + email if !email.blank? && email != ''

          begin
            # workgin
            title = kiosk.title.nil? ? 'Kiosk' : kiosk.title

           

            #CAPTURE
            cres = RestClient.post("#{kiosk.user.merchant_end_point}/cardconnect/rest/capture", { 'merchid' => kiosk.user.merchid, 'retref' => response['retref'], 'items' => [{ 'description' => 'Donation for ' + title + string_email }] }.to_json, { 'Authorization' => 'Basic ' + Base64.strict_encode64(cred_combo), :content_type => 'application/json' })

            cresponse = JSON.parse(cres.body)
            @response = { 'status' => '! ' + cresponse['setlstat'], 'retref' => cresponse['retref'],  'amount' => amount , 'title' => title }

            if cresponse['setlstat'] != 'Rejected'

              params[:kiosk][:donations_attributes]['0'][:cardconnectref] = cresponse['retref']

              if kiosk.update(donation_params)

                if !email.blank? && email != ''
                  charge = { 'email' => email, 'name' => name, 'amount' => amount, 'retref' => cresponse['retref'], 'kiosk_title' => title, 'inv_num' => inv_num, 'inv_desc' => inv_desc }
                  KioskMailer.receipt_email(charge).deliver
                end

                charge = { 'email' => kiosk.user.email, 'name' => name, 'amount' => amount, 'kiosk_name' => title, 'inv_num' => inv_num, 'inv_desc' => inv_desc, 'retref' => cresponse['retref'], }
                KioskMailer.owner_email(charge).deliver



               if kiosk.sms_number.length > 6
                
               # require 'signalwire/sdk'

                require 'signalwire/relay/task'

                task = Signalwire::Relay::Task.new(project: "3fe73725-f958-4c16-ad94-be32579bed82",  token: "PT23fade6437f208048a783979382fa088bf9fc6bd06e507d5")

               
                
                




                 # @client = Signalwire::REST::Client.new '3fe73725-f958-4c16-ad94-be32579bed82', 'PT23fade6437f208048a783979382fa088bf9fc6bd06e507d5', signalwire_space_url: "startgroup.signalwire.com"

                  collected = 'was'
                  if fee == 0
                    collected = 'was not'

                  end
                  



                  body = 'You have received a payment from '+name+', for the amount of '+ActiveSupport::NumberHelper.number_to_currency(amount)+'. A gateway fee '+collected+' collected for this transaction. Thank you!'
                  body = 'esy'

                  message = {
                    'action': 'call',
                    'from': '+14327296690',
                    to: kiosk.sms_number,
                  }

                  result = task.deliver(context: 'incoming', message: body)

                  # message = @client.messages.send(
                  #   from: '+14158140047',
                  #   body: body,
                  #   to: kiosk.sms_number
                  # )
#                   @client.messages.send(
#                   from: '+14158140047',
#   to: '+14158140047',
#   body: 'SignalWire says hello!'
# )
                  


                end



              end
              # is Rejected
            else
              @response = { 'errors' => 'Request Declined! ' + response.setlstat }
            end
          rescue Exception => e
            #error from mailer..should be considered success
            if e.message.include? " recipient is required"

              charge = { 'email' => kiosk.user.email, 'name' => name, 'amount' => amount, 'kiosk_name' => title, 'inv_num' => inv_num, 'inv_desc' => inv_desc, 'retref' => cresponse['retref'], }
              KioskMailer.owner_email(charge).deliver
              #do nothgin..we already have @response..just send ownder mail
            else  
              @response = { 'errors' => e }
            end  
          end

        # respstat is not 'A'
        else
          @response = { 'errors' => 'Request Declined! ' + response['resptext'] }
       end
         # amount is not < '0'
       end
    rescue Exception => e
      p e.backtrace.join("\n")
      @response = { 'errors' => e }
    end


    respond_to do |format|
      format.js {}
    end
  end

  def invite
    @kiosk = Kiosk.find(params[:id])

    if params.include?(:kiosk)
      KioskMailer.invite_email(params[:kiosk][:email], params[:kiosk][:subject], params[:kiosk][:mail_content]).deliver
      # mail(to: params[:kiosk][:email], subject: params[:kiosk][:subject], content: params[:kiosk][:mail_content])
      render 'invited'
    end
  end

  private

  def donation_params
    params.require(:kiosk).permit(donations_attributes: %i[title name email amount cardconnectref inv_num inv_desc])
  end
end
