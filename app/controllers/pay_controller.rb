class PayController < NoAuthController
  layout "paylayout", only: [:show]
  

  def show

 
    #slug
    if params[:id]
      @kiosk = Kiosk.find_by(slug: params[:id])
    elsif params[:kid]
      @kiosk = Kiosk.find(params[:kid])
    end

    
    p @kiosk.inspect
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
    cvc = params[:cvv]
    exp = params[:exp].sub('/','').to_s
    amount = params[:amount].gsub!(/\$|\,/, "")
    number = params[:cardnumber].sub(' ','').to_s
    name = params[:name]
    email = params[:email]

    percent = kiosk.user.scharge_percent
		percent = (percent / 100) 
		fee =  amount.to_f * percent


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

    orig_amt = amount.to_f
    amount = amount.to_f + fee.to_f

   
    cparams = { 'merchid' => kiosk.user.merchid, 'amount' => amount, 'expiry' => exp, 'account' => number, 'currency' => 'USD', 'name' => name, 'ecomind' => 'E', 'cvv2' => cvc , 'postal' => zip,  'email' => email}

   
    cred_combo = "#{kiosk.user.merchant_username}:#{kiosk.user.merchant_password}"
    #just AUTH  
    res = RestClient.post("#{kiosk.user.merchant_end_point}/cardconnect/rest/auth", cparams.to_json, { 'Authorization' => 'Basic ' + Base64.strict_encode64(cred_combo), :content_type => 'application/json' })


  
    formdata = {:fee => fee.to_f, :ctype => ctype, :orig_amt => orig_amt, :amount => amount}
    session[:formdata] = formdata
    response = JSON.parse(res.body)

   

    render :json =>  response


  end


  def ajx_charge_s2
    kiosk = Kiosk.find(params[:kid])
    retref = params[:retref]
    cred_combo = "#{kiosk.user.merchant_username}:#{kiosk.user.merchant_password}"
    title = kiosk.title.nil? ? 'Kiosk' : kiosk.title
    zip = params[:zip]
    email = params[:email]
    inv_num =  params[:invoice]
    inv_desc =  params[:description]

     name = params[:name]


    cres = RestClient.post("#{kiosk.user.merchant_end_point}/cardconnect/rest/capture", { 'merchid' => kiosk.user.merchid, 'retref' => retref,
              "userfields" =>  [
                {
                    "zip" => zip,
                    "title" => title,

                },]
          }.to_json, { 'Authorization' => 'Basic ' + Base64.strict_encode64(cred_combo), :content_type => 'application/json' })

    cresponse = JSON.parse(cres.body)
    

 


    #params[:kiosk][:donations_attributes]['0'][:cardconnectref] = retref

     #         params[:kiosk][:donations_attributes]['0'][:donated_by] = current_user.id
            

              setlstat = (cresponse['setlstat'] == "Queued for Capture") ? "Approved" : cresponse['setlstat']



              if kiosk.user.notify_sms_hpp &&   kiosk.sms_number

                print "sedindding messge 555"
                sms_number = "+1"+kiosk.sms_number
                print "=======================================================================>>>>>>>"
                print sms_number
                collected = 'was'
                if session[:formdata]["fee"] == 0
                  collected = 'was not'

                end

                body = 'You have received a payment from '+name+', for the amount of '+ActiveSupport::NumberHelper.number_to_currency(session[:formdata]["amount"])+'. A gateway fee '+collected+' collected for this transaction. Thank you!'



                require 'signalwire/sdk'

                @client = Signalwire::REST::Client.new '3fe73725-f958-4c16-ad94-be32579bed82', 'PT23fade6437f208048a783979382fa088bf9fc6bd06e507d5', signalwire_space_url: "startgroup.signalwire.com"


                message = @client.messages.create(
                                            from: '+14327296690',
                                            body: body,
                                            to:  sms_number
                                          )
              end




              params = {cardconnectref: retref, gateway_fee: session[:formdata]["fee"], card_type: session[:formdata]["ctype"], tx_status: setlstat, authcode: cresponse['authcode'], inv_num: inv_num, inv_desc: inv_desc,kiosk_id: kiosk.id, email: email, name: name, amount: session[:formdata]["orig_amt"]}

              if current_user  
                params["donated_by"] = current_user.id
              end 


              if Donation.create( params )

                if !email.blank? && email != ''
                  charge = { 'email' => email, 'name' => name, 'amount' => session[:formdata]["amount"], 'retref' => cresponse['retref'], 'kiosk_title' => title, 'inv_num' => inv_num, 'inv_desc' => inv_desc }
                  KioskMailer.receipt_email(charge).deliver
                end

                charge = { 'email' => kiosk.user.email, 'name' => name, 'amount' => session[:formdata]["amount"], 'kiosk_name' => title, 'inv_num' => inv_num, 'inv_desc' => inv_desc, 'retref' => cresponse['retref'], }
                KioskMailer.owner_email(charge).deliver

              end





    if(cresponse['setlstat'])
      response = { 'setlstat' => cresponse['setlstat'], 'retref' => cresponse['retref'] }      
    else
      response = { 'setlstat' => 'Rejected' }      
    end
    render :json => response

    
  end


end
