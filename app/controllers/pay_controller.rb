class PayController < NoAuthController
  layout "paylayout", only: [:show]
  

  def show

 
    #slug
    if params[:id]
      @kiosk = Kiosk.find_by("slug ILIKE ?", params[:id])
    elsif params[:kid]
      @kiosk = Kiosk.find(params[:kid])
    end

    
    render 'payment-form' 
#    render :json => {:donations => "sdfsdf"}

    # @kiosk = Kiosk.find(params[:id])
    # @user = User.find(@kiosk.user_id)



  end


  
  def ajx_charge_s1

    #will be passed to s2
    session[:formdata] = []

    orig_amt = 0
    id = params[:kid]
    kiosk = Kiosk.find(id)

    zip = params[:zip]
    amount = params[:amount].gsub!(/\$|\,/, "")
    number = params[:cardnumber].sub(' ','').to_s
    name = params[:name]
    email = params[:email]

    percent = kiosk.user.scharge_percent
		percent = (percent / 100) 
		fee =  amount.to_f * percent


    first8dig = number.to_s[0..7]
    last4 = number.to_s.last(4)

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

    orig_amt = amount.to_f

    if orig_amt < 0
      raise 'Incorrect amount'
    end  
    amount = amount.to_f + fee.to_f

   
    # 


  
    formdata = {:fee => fee.to_f, :ctype => ctype, :orig_amt => orig_amt, :amount => amount, :last4 => last4}
    session[:formdata] = formdata
    #response = JSON.parse(res.body)


    render :json =>  formdata


  end


  def ajx_charge_s2
    sms_param_included = ""
    kiosk = Kiosk.find(params[:kid])
    cred_combo = "#{kiosk.user.merchant_username}:#{kiosk.user.merchant_password}"
    title = kiosk.title.nil? ? 'Kiosk' : kiosk.title
    zip = params[:zip]
    email = params[:email]
    inv_num =  params[:invoice]
    inv_desc =  params[:description]
    company =  params[:company]
    name = params[:name]
    tip_amt = params[:tip_amt]
    tip_percent = params[:tip_percent]
    emp = params[:emp]
    number = params[:cardnumber].sub(' ','').to_s
    exp = params[:exp].sub('/','').to_s
    cvc = params[:cvv]
    final_amt = session[:formdata]["amount"] + tip_amt.to_f

    
    
    #speical case coming from mobile.paynow

    if request.referrer && URI.parse(request.referrer).query
      uri = CGI.parse(URI.parse(request.referrer).query)
      if uri
        if uri["sms"]
          sms_param_included = uri["sms"][0].to_s
        end
      end
    end  


    cparams = { 'merchid' => kiosk.user.merchid, 'amount' => final_amt, 'expiry' => exp, 'account' => number, 'currency' => 'USD', 'name' => name, 'ecomind' => 'E', 'cvv2' => cvc , 'postal' => zip,  'email' => email, "userfields" =>  [
                  {
                      "zip" => zip,
                      "title" => title,
                      "tip_amt" => tip_amt,
                      "orig_amt" => session[:formdata]["orig_amt"],
                      "fee" => session[:formdata]["fee"],
                      "tip_percent" => tip_percent,

                  },]}

   
    cred_combo = "#{kiosk.user.merchant_username}:#{kiosk.user.merchant_password}"


    # AUTH  & capture
    cres = RestClient.post("#{kiosk.user.merchant_end_point}/cardconnect/rest/auth", cparams.to_json, { 'Authorization' => 'Basic ' + Base64.strict_encode64(cred_combo), :content_type => 'application/json' })



    # cres = RestClient.post("#{kiosk.user.merchant_end_point}/cardconnect/rest/capture", { 'merchid' => kiosk.user.merchid, 'retref' => retref,
    #           "userfields" =>  [
    #             {
    #                 "zip" => zip,
    #                 "title" => title,

    #             },]
    #       }.to_json, { 'Authorization' => 'Basic ' + Base64.strict_encode64(cred_combo), :content_type => 'application/json' })

    cresponse = JSON.parse(cres.body)
    

              setlstat = (cresponse['respstat'] == "A") ? "Approved" : cresponse['resptext']


              if (cresponse['respstat'] == 'A') 

                if ((kiosk.user.notify_sms_hpp && kiosk.user.phone) || sms_param_included.length > 8) 

                  sms_number = (sms_param_included.length > 8)? sms_param_included : kiosk.user.phone

                  sms_number = "+1"+sms_number
                  collected = 'was'
                  if session[:formdata]["fee"] == 0
                    collected = 'was not'

                  end

                  body = 'You have received a payment from '+name+', for the amount of '+ActiveSupport::NumberHelper.number_to_currency(final_amt)+'. A gateway fee '+collected+' collected for this transaction. Thank you!'



                  require 'signalwire/sdk'

                  @client = Signalwire::REST::Client.new '3fe73725-f958-4c16-ad94-be32579bed82', 'PT23fade6437f208048a783979382fa088bf9fc6bd06e507d5', signalwire_space_url: "startgroup.signalwire.com"


                  message = @client.messages.create(
                                              from: '+14327296690',
                                              body: body,
                                              to:  sms_number
                                            )
                end




                params = {cardconnectref: cresponse['retref'], gateway_fee: session[:formdata]["fee"], card_type: session[:formdata]["ctype"], tx_status: setlstat, authcode: cresponse['authcode'], inv_num: inv_num, inv_desc: inv_desc,kiosk_id: kiosk.id, email: email, name: name, amount: session[:formdata]["orig_amt"], company: company, last4: session[:formdata]["last4"], tip_amt: tip_amt, emp: emp}

                if current_user  
                  params["donated_by"] = current_user.id
                end 


                if donation = Donation.create( params )


                  if !email.blank? && email != ''
                    charge = { 'email' => email, 'name' => name, 'amount' => final_amt, 'retref' => cresponse['retref'], 'kiosk_title' => title, 'inv_num' => inv_num, 'inv_desc' => inv_desc , 'tip_amt' => tip_amt, 'fee' => session[:formdata]["fee"], 'orig_amt' => session[:formdata]["orig_amt"], 'created_at' => donation.created_at.in_time_zone(current_user.tz).strftime("%^b %d, %Y %H:%M %p") }
                    KioskMailer.receipt_email(charge).deliver
                  end

                  if kiosk.user.notify_email_hpp
                    charge = { 'email' => kiosk.user.email, 'owner_name' => kiosk.user.fname,  'name' => name, 'amount' => final_amt, 'kiosk_name' => title, 'inv_num' => inv_num, 'inv_desc' => inv_desc, 'retref' => cresponse['retref'], 'company' => company, 'last4' => session[:formdata]["last4"], 'tip_amt' => tip_amt, 'fee' => session[:formdata]["fee"], 'orig_amt' => session[:formdata]["orig_amt"],  'emp' => emp, 'created_at' => donation.created_at.in_time_zone(current_user.tz).strftime("%^b %d, %Y %H:%M %p")}
                    KioskMailer.owner_email(charge).deliver
                  end

                end






        response = { 'setlstat' => setlstat, 'retref' => cresponse['retref'] }      
     
    else
      response = { 'setlstat' => setlstat}      
    end

    render :json => response

    
  end


end
