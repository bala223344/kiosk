class KiosksController < BaseController

  def vt
    if (current_user && current_user.kiosk && current_user.kiosk.id)
      @kiosk = current_user.kiosk
      @user = current_user
      page = (params[:page]?params[:page]:0)
      @donations = current_user.donations.order('id desc').page(page).per(20)
    else
      @kiosk = nil
      @user = nil
    end
    render 'show'

    #@kiosk = current_user.find(params[:id])
    #render 'show'
  end
  def show
    
    @kiosk = Kiosk.find(params[:id])
    @user = User.find(@kiosk.user_id)

    

  end


  def refund 
    donation = Donation.find(params[:kiosk][:id])
    kiosk = donation.kiosk



    cred_combo = "#{kiosk.user.merchant_username}:#{kiosk.user.merchant_password}"

    cres = RestClient.post("#{kiosk.user.merchant_end_point}/cardconnect/rest/refund", { 'merchid' => kiosk.user.merchid, 'retref' => donation.cardconnectref }.to_json, { 'Authorization' => 'Basic ' + Base64.strict_encode64(cred_combo), :content_type => 'application/json' })

    cresponse = JSON.parse(cres.body)
    if cresponse['respstat'] == 'A'


      donation.tx_status = 'refunded'
      donation.save
      # dobj = Donation.new   
      # dobj.cardconnectref = cresponse['retref']
      # dobj.amount = cresponse['amount']
      # dobj.tx_status = 'refunded'
      # dobj.kios_id = kiosk.id
      # dobj.save

      # if kiosk.update(donation_params)

      #   if !email.blank? && email != ''
      #     charge = { 'email' => email, 'name' => name, 'amount' => amount, 'retref' => cresponse['retref'], 'kiosk_title' => title, 'inv_num' => inv_num, 'inv_desc' => inv_desc }
      #     KioskMailer.receipt_email(charge).deliver
      #   end
      #   charge = { 'email' => kiosk.user.email, 'name' => name, 'amount' => amount, 'kiosk_name' => title, 'inv_num' => inv_num, 'inv_desc' => inv_desc, 'retref' => cresponse['retref'], }
      #   KioskMailer.owner_email(charge).deliver
      # end


      respond_to do |format|
        format.js { render :json => {:success => true,  status: :created }}
      end
    else
      respond_to do |format|
        format.js { render :json => {:success => false, :errors =>cresponse['resptext'], }, status: :unprocessable_entity  }
      end
   end

   

  end

  


  def new
    @kiosk = Project.new

  end

  def bin

    number = params[:number]
    first8dig = number.to_s[0..7]
    ccres = RestClient.get("https://lookup.binlist.net/#{first8dig}", { 'Accept-Version' => '3'})
    render json: ccres.body
  end

  def update
    id = params[:id]
    kiosk = Kiosk.find(id)

    number = params[:number]
    zip = params[:zip]
    cvc = params[:cvc]
    exp_mn = params[:exp_mn].to_s
    exp_yr = params[:exp_yr].to_s
    amount = params[:kiosk][:donations_attributes]['0'][:amount]
    fee = params[:kiosk][:donations_attributes]['0'][:fee_amt]
    service_fee = params[:kiosk][:donations_attributes]['0'][:service_fee]

    inv_num = params[:kiosk][:donations_attributes]['0'][:inv_num]
    inv_desc = params[:kiosk][:donations_attributes]['0'][:inv_desc]
    name = params[:kiosk][:donations_attributes]['0'][:name]
    email = params[:kiosk][:donations_attributes]['0'][:email]
    
    

    begin

       first8dig = number.to_s[0..7]
        ccres = RestClient.get("https://lookup.binlist.net/#{first8dig}", { 'Accept-Version' => '3'})
        ccbody = JSON.parse(ccres.body)
        ctype = 'credit'
        #no CC..no fee
        #if model is surcharge fee is only for credit card..determin if it is not a CC
        if ccbody["type"] != "credit"
          if kiosk.user.cmodel == 'surcharge'
            fee = 0
          end 
          ctype = 'debit'
        end 

        # no service fee if checkbox is disabled  
        if service_fee == "0"
          fee = 0
        end


      amount = amount.to_f + fee.to_f
      if amount < 0
        @response = { 'errors' => 'Invalid amount' }
      else
        cparams = { 'merchid' => kiosk.user.merchid, 'amount' => amount, 'expiry' => exp_mn + exp_yr, 'account' => number, 'currency' => 'USD', 'name' => name, 'ecomind' => 'E', 'cvv2' => cvc , 'postal' => zip,  'email' => email}

        cred_combo = "#{kiosk.user.merchant_username}:#{kiosk.user.merchant_password}"
        #just AUTH  
        res = RestClient.post("#{kiosk.user.merchant_end_point}/cardconnect/rest/auth", cparams.to_json, { 'Authorization' => 'Basic ' + Base64.strict_encode64(cred_combo), :content_type => 'application/json' })

      
        response = JSON.parse(res.body)

       

        #byebug
        if response['respstat'] == 'A'
          string_email = ''
          string_email = 'from ' + email if !email.blank? && email != ''

          begin
            # workgin
            title = kiosk.title.nil? ? 'Kiosk' : kiosk.title
            #CAPTURE
            cres = RestClient.post("#{kiosk.user.merchant_end_point}/cardconnect/rest/capture", { 'merchid' => kiosk.user.merchid, 'retref' => response['retref'],
              "userfields" =>  [
                {
                    "zip" => zip,
                    "title" => title,

                },]
          }.to_json, { 'Authorization' => 'Basic ' + Base64.strict_encode64(cred_combo), :content_type => 'application/json' })

            cresponse = JSON.parse(cres.body)


            p "authcodeauthcodeauthcodeauthcode"
            p cresponse.inspect

            @response = { 'status' => '! ' + cresponse['setlstat'], 'retref' => cresponse['retref'],  'amount' => amount , 'title' => title, 'merchid' => kiosk.user.merchid }

            if cresponse['setlstat'] != 'Rejected'

              params[:kiosk][:donations_attributes]['0'][:cardconnectref] = cresponse['retref']

              params[:kiosk][:donations_attributes]['0'][:donated_by] = current_user.id
              params[:kiosk][:donations_attributes]['0'][:gateway_fee] = fee
              params[:kiosk][:donations_attributes]['0'][:card_type] = ctype
              params[:kiosk][:donations_attributes]['0'][:tx_status] = cresponse['setlstat']
              params[:kiosk][:donations_attributes]['0'][:authcode] = cresponse['authcode']
              

              if kiosk.update(donation_params)

                if !email.blank? && email != ''
                  charge = { 'email' => email, 'name' => name, 'amount' => amount, 'retref' => cresponse['retref'], 'kiosk_title' => title, 'inv_num' => inv_num, 'inv_desc' => inv_desc }
                  KioskMailer.receipt_email(charge).deliver
                end

                charge = { 'email' => kiosk.user.email, 'name' => name, 'amount' => amount, 'kiosk_name' => title, 'inv_num' => inv_num, 'inv_desc' => inv_desc, 'retref' => cresponse['retref'], }
                KioskMailer.owner_email(charge).deliver

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
      format.js {render json: @response }
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
    params.require(:kiosk).permit(donations_attributes: %i[title name email amount cardconnectref inv_num inv_desc donated_by gateway_fee card_type tx_status zip authcode])
  end
end
