class KiosksController < BaseController

  def vt
    if (current_user && current_user.kiosk && current_user.kiosk.id)
      @kiosk = current_user.kiosk
      @user = current_user
      page = (params[:page]?params[:page]:1)
      @donations = current_user.kiosk.donations.order('id desc').page(page).per(20)
      @tz = current_user.tz
    else
      @kiosk = nil
      @user = nil
    end
    render 'show'

    #@kiosk = current_user.find(params[:id])
    #render 'show'
  end



  def online
    if (current_user && current_user.kiosk && current_user.kiosk.id)
      @kiosk = current_user.kiosk
      @donations = current_user.donations
      @collection =  Donation.where(kiosk_id: current_user.kiosk.id).where("tx_status = 'Approved'").sum(:amount)
      @gateway_fee = Donation.where(kiosk_id: current_user.kiosk.id).where("tx_status = 'Approved'").sum(:gateway_fee)

    else
      @kiosk = nil
    end


  end


  def submit_online



    if !params[:email].blank? && params[:email] != ''
      amount = params[:amount].sub(',','')
      url = params[:url]+"?inv_num=#{params[:inv_num]}&inv_desc=#{params[:inv_desc]}&amount=#{amount}"
      charge = { 'email' => params[:email],  'amount' => amount , 'kiosk_title' => params[:kiosk_title], 'url' => url , 'inv_num' => params[:inv_num], 'inv_desc' => params[:inv_desc] }
      KioskMailer.online_email(charge).deliver
    end

  end






  def donation_detail
    donation = current_user.kiosk.donations.find(params[:id])

    temp = Hash.new

    temp["date"] = donation.created_at.in_time_zone(current_user.tz).strftime("%^b %d, %Y %H:%M %p")
    temp["id"] = donation.id
    temp["amount"] = ActiveSupport::NumberHelper.number_to_currency(donation.amount.to_f) 
    temp["name"] = donation.name
    temp["email"] = donation.email
    temp["merchid"] = donation.kiosk.user.merchid
    temp["authcode"] = donation.authcode
    temp["card_type"] = donation.card_type
    temp["gateway_fee"] = ActiveSupport::NumberHelper.number_to_currency(donation.gateway_fee)
    temp["status"] = donation.tx_status
    temp["total_charged"] = ActiveSupport::NumberHelper.number_to_currency(donation.amount.to_f +  donation.gateway_fee.to_f)

    temp["cardconnectref"] =  donation.cardconnectref
    temp["inv_num"] = donation.inv_num
    temp["inv_desc"] = donation.inv_desc
    temp["company"] = donation.company
    temp["tx_status"] = donation.tx_status
    temp["last4"] = donation.last4
    temp["tip_amt"] = ActiveSupport::NumberHelper.number_to_currency(donation.tip_amt)
    temp["emp"] = donation.emp



     #

    render :json => {:donation =>  temp }

  end

  def reporting

    respond_to do |format|

      if (current_user && current_user.kiosk && current_user.kiosk.id)
        format.html {
          render 'reporting'
        }
        format.json {
          page = (params[:page]?params[:page]:1)
          recs = current_user.kiosk.donations
          #recs = Donations.where(kiosk_id: current_user.kiosk.id)
          q  = params[:q]
          sort_order = params[:sort_order]
          sort_field = params[:sort_field]
          ctype =  params[:ctype]
          tx_status = params[:tx_status]

         # donations = donations.where("tx_status = ?", "refunded")
         if q 
            #don;t compare if it is too large..may be ref id
          if q.to_s =~ /\A[-+]?\d*\.?\d+\z/ and q.length < 7
            #if an int include id as well
            if Integer(q ,  exception: false)
              recs = recs.where("amount = ? OR gateway_fee = ? OR id = ?", q, q, q)
            else 
              #dont bother abt id
              recs = recs.where("amount = ? OR gateway_fee = ?", q, q)
            end

          else
            recs = recs.where("tx_status LIKE ? OR email LIKE ? OR name LIKE ? OR card_type LIKE ? OR cardconnectref LIKE ?", "%#{q}%", "%#{q}%", "%#{q}%", "%#{q}%", "%#{q}%")
          end
         end

         if ctype
          recs = recs.where("card_type LIKE ?", "%#{ctype}%")
         end

         if tx_status
          recs = recs.where("tx_status LIKE ?", "%#{tx_status}%")
         end

         order = 'id desc'
         if sort_field 
          order = "#{sort_field} #{sort_order}"
         end

         

         recs = recs.order(order).page(page).per(20)
          
          donations = []

          recs.each do |donation|  

            temp = Hash.new
            temp["date"] = donation.created_at.in_time_zone(current_user.tz).strftime("%^b %d, %Y %I:%M %p")
            temp["id"] = donation.id
            temp["amount"] = ActiveSupport::NumberHelper.number_to_currency(donation.amount) 
            temp["name"] = donation.name
            temp["card_type"] = donation.card_type
            temp["gateway_fee"] = ActiveSupport::NumberHelper.number_to_currency(donation.gateway_fee)
            temp["tx_status"] =  donation.tx_status
            temp["company"] =  donation.company
            temp["inv_num"] =  donation.inv_num
            temp["tip_amt"] =  ActiveSupport::NumberHelper.number_to_currency(donation.tip_amt)
           #
            donations.push(temp)
          end

          render :json => {:donations =>  donations, :total_count => recs.total_count, :kiosk_title => current_user.kiosk.title }
        }

      end
    end


    # if (current_user && current_user.kiosk && current_user.kiosk.id)
    #   render 'reporting'
    
    #   render :json => {:donations => @donations}

    # else
    #   @kiosk = nil
    #   @user = nil
    # end
    # render 'reporting'

  end



  def sendreceipt
    donation = Donation.find(params[:kiosk][:id])



    KioskMailer.modal_receipt_email(donation).deliver

  end


  def slugupdate

    kiosk = Kiosk.find(params[:id])
    kiosk.slug = params[:slug]
    kiosk.save
   
   # KioskMailer.modal_receipt_email(donation).deliver

  end
  def refund 

    donation = Donation.find(params[:kiosk][:id])
    kiosk = donation.kiosk

    cred_combo = "#{kiosk.user.merchant_username}:#{kiosk.user.merchant_password}"


    rres = RestClient.get("#{kiosk.user.merchant_end_point}/cardconnect/rest/inquire/#{donation.cardconnectref}/#{kiosk.user.merchid}",  { 'Authorization' => 'Basic ' + Base64.strict_encode64(cred_combo), :content_type => 'application/json' })

    
    rresponse = JSON.parse(rres.body)

    if rresponse["voidable"] == "Y"

      cres = RestClient.post("#{kiosk.user.merchant_end_point}/cardconnect/rest/void", { 'merchid' => kiosk.user.merchid, 'retref' => donation.cardconnectref }.to_json, { 'Authorization' => 'Basic ' + Base64.strict_encode64(cred_combo), :content_type => 'application/json' })
      donation.tx_status = 'Voided'
    else

      
      cres = RestClient.post("#{kiosk.user.merchant_end_point}/cardconnect/rest/refund", { 'merchid' => kiosk.user.merchid, 'retref' => donation.cardconnectref }.to_json, { 'Authorization' => 'Basic ' + Base64.strict_encode64(cred_combo), :content_type => 'application/json' })

      donation.tx_status = 'Refunded'

    end


    cresponse = JSON.parse(cres.body)
    if cresponse['respstat'] == 'A'
      donation.save
  
      respond_to do |format|
        format.js { render :json => {:success => true,  status: :created }}
        format.html { render :json => {:success => true,  status: :created }}
        format.json { render :json => {:success => true,  status: :created }}

      end

    else
      respond_to do |format|
        format.js { render :json => {:success => false, :errors =>cresponse['resptext'], }, status: :unprocessable_entity  }
        format.html { render :json => {:success => false, :errors =>cresponse['resptext'], }, status: :unprocessable_entity  }
        format.json { render :json => {:success => false, :errors =>cresponse['resptext'], }, status: :unprocessable_entity  }

      end
   end


  end

  



  def new

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



            @response = { 'status' => '! ' + cresponse['setlstat'], 'retref' => cresponse['retref'],  'amount' => amount , 'title' => title, 'merchid' => kiosk.user.merchid }

            if cresponse['setlstat'] != 'Rejected'

              params[:kiosk][:donations_attributes]['0'][:cardconnectref] = cresponse['retref']

              params[:kiosk][:donations_attributes]['0'][:donated_by] = current_user.id
              params[:kiosk][:donations_attributes]['0'][:gateway_fee] = fee
              params[:kiosk][:donations_attributes]['0'][:card_type] = ctype

              setlstat = (cresponse['setlstat'] == "Queued for Capture") ? "Approved" : cresponse['setlstat']

              params[:kiosk][:donations_attributes]['0'][:tx_status] = setlstat

             

              params[:kiosk][:donations_attributes]['0'][:authcode] = cresponse['authcode']
              params[:kiosk][:donations_attributes]['0'][:last4] = last4
              params[:kiosk][:donations_attributes]['0'][:company] = params[:company]
              

              if kiosk.update(donation_params)

                if !email.blank? && email != ''
                  charge = { 'email' => email, 'name' => name, 'amount' => amount, 'retref' => cresponse['retref'], 'kiosk_title' => title, 'inv_num' => inv_num, 'inv_desc' => inv_desc }
                  KioskMailer.receipt_email(charge).deliver
                end

                charge = { 'email' => kiosk.user.email, 'name' => name, 'amount' => amount, 'kiosk_name' => title, 'inv_num' => inv_num, 'inv_desc' => inv_desc, 'retref' => cresponse['retref'], 'company' => params[:company], 'last4' => last4}
                KioskMailer.owner_email(charge).deliver


             





              end
              # is Rejected
            else
              @response = { 'errors' => 'Request Declined! ' + response.setlstat }
            end
          rescue Exception => e
            #error from mailer..should be considered success
            if e.message.include? " recipient is required"

              charge = { 'email' => kiosk.user.email, 'name' => name, 'amount' => amount, 'kiosk_name' => title, 'inv_num' => inv_num, 'inv_desc' => inv_desc, 'retref' => cresponse['retref'], 'company' => params[:company], 'last4' => last4}
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


  def update_kiosk_pref
    @kiosk = current_user.kiosk
    if @kiosk.update(profile_params)

    end

  end

  def update_profile
    @kiosk = current_user.kiosk
    if @kiosk.update(profile_params)
     redirect_to edit_user_path(current_user)
    else
      redirect_to edit_user_path(current_user)
    end

  end
  private

  def donation_params
    params.require(:kiosk).permit(donations_attributes: %i[title name email amount cardconnectref inv_num inv_desc donated_by gateway_fee card_type tx_status zip authcode last4 company])
  end

  def profile_params
    params.require(:kiosk).permit(:title, :sms_number, :city, :zip, :state, :staddr, :website, :slogan, :tips )
  end
end
