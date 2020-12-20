class PayController < BaseController
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
		fee =  amount * percent


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

  


    amount = amount.to_f + fee.to_f


   
    cparams = { 'merchid' => kiosk.user.merchid, 'amount' => amount, 'expiry' => exp, 'account' => number, 'currency' => 'USD', 'name' => name, 'ecomind' => 'E', 'cvv2' => cvc , 'postal' => zip,  'email' => email}

   
    cred_combo = "#{kiosk.user.merchant_username}:#{kiosk.user.merchant_password}"
    #just AUTH  
    res = RestClient.post("#{kiosk.user.merchant_end_point}/cardconnect/rest/auth", cparams.to_json, { 'Authorization' => 'Basic ' + Base64.strict_encode64(cred_combo), :content_type => 'application/json' })

  
    response = JSON.parse(res.body)

   

    render :json =>  response


  end


  def ajx_charge_s2
    kiosk = Kiosk.find(params[:id])
    retref = params[:retref]
    cred_combo = "#{kiosk.user.merchant_username}:#{kiosk.user.merchant_password}"

    cres = RestClient.post("#{kiosk.user.merchant_end_point}/cardconnect/rest/capture", { 'merchid' => kiosk.user.merchid, 'retref' => retref,
              "userfields" =>  [
                {
                    "zip" => "545454",
                    "title" => "title",

                },]
          }.to_json, { 'Authorization' => 'Basic ' + Base64.strict_encode64(cred_combo), :content_type => 'application/json' })

    cresponse = JSON.parse(cres.body)
    p cresponse.inspect
    if(cresponse['setlstat'])
      response = { 'setlstat' => cresponse['setlstat'], 'retref' => cresponse['retref'] }      
    else
      response = { 'setlstat' => 'Rejected' }      
    end
    render :json => response

    
  end


end
