class KiosksController < ApplicationController
  def show

     @kiosk = Kiosk.find(params[:id])
     @user = User.find(@kiosk.user_id)

   
  end

def new
 @kiosk = Project.new
end

 def update
   begin
      id = params[:id]
      kiosk = Kiosk.find(id)

      number = params[:number]
      cvc = params[:cvc]
      exp_mn = params[:exp_mn].to_s
      exp_yr = params[:exp_yr].to_s
      amount = params[:kiosk][:donations_attributes]["0"][:amount]

      inv_num = params[:kiosk][:donations_attributes]["0"][:inv_num]
      inv_desc = params[:kiosk][:donations_attributes]["0"][:inv_desc]
      name = params[:kiosk][:donations_attributes]["0"][:name]
      email = params[:kiosk][:donations_attributes]["0"][:email]



        #  CardConnect.configuration.api_username = kiosk.user.merchant_username
        #  CardConnect.configuration.api_password = kiosk.user.merchant_password
        #  if kiosk.user.merchant_end_point.nil? 
        #   CardConnect.configuration.endpoint = 'https://fts.cardconnect.com:6443'
          
        #  else
        #   CardConnect.configuration.endpoint = kiosk.user.merchant_end_point
         
        #  end 


      begin
        amount = amount.to_f
        if amount < 0
          @response = {"errors" => "Invalid amount"}
        else
          cparams = {"merchid" => kiosk.user.merchid, "amount" => amount, "expiry" => exp_mn+exp_yr, "account" => number, "currency"=>"USD","name"=>name, "ecomind"=>"E","cvv2"=>cvc}

#          params = {"merchid" => '800000000843', "amount" => '0.01', "expiry" => '0224', "account" => '4000000000000077'}
          cred_combo = "#{kiosk.user.merchant_username}:#{kiosk.user.merchant_password}"

          #working
          #res = RestClient.post("https://fts-uat.cardconnect.com/cardconnect/rest/auth",  {"merchid" => '800000000843', "amount" => '0.01', "expiry" => '0224', "account" => '4000000000000077'}.to_json,  {"Authorization" => "Basic "+ Base64::strict_encode64(cred_combo), :content_type=> 'application/json' })


          res = RestClient.post("#{kiosk.user.merchant_end_point}/cardconnect/rest/auth",  cparams.to_json,  {"Authorization" => "Basic "+ Base64::strict_encode64(cred_combo), :content_type=> 'application/json' })
          response = JSON.parse(res.body)

            if(response["respstat"] == "A")
             string_email = ""
              if !email.blank? && email != ""
                string_email = "from "+email
              end



             begin


                  #workgin
                  cres = RestClient.post("#{kiosk.user.merchant_end_point}/cardconnect/rest/capture",  {"merchid" => kiosk.user.merchid, "retref" => response["retref"], "items" => [{"description" => "Donation for "+kiosk.title + string_email}]}.to_json,  {"Authorization" => "Basic "+ Base64::strict_encode64(cred_combo), :content_type=> 'application/json' })
                  

                  
                  cresponse = JSON.parse(cres.body)
                   @response = {"status" => "! "+cresponse["setlstat"], "retref" => cresponse["retref"]}

                   if (cresponse["setlstat"] != 'Rejected')

                    params[:kiosk][:donations_attributes]["0"][:cardconnectref] = cresponse["retref"]

                     if kiosk.update(donation_params)

                       if !email.blank? && email != ""
                           charge = {"email" => email, "name" => name,"amount" => amount, "retref" => cresponse["retref"], "kiosk_title" =>  kiosk.title, "inv_num" => inv_num, "inv_desc" => inv_desc}
                           KioskMailer.receipt_email(charge).deliver
                       end

                       charge = {"email" => kiosk.user.email, "name" => name, "amount" => amount,"kiosk_name" => kiosk.title, "inv_num" => inv_num, "inv_desc" => inv_desc}
                       KioskMailer.owner_email(charge).deliver
                     end
                     #is Rejected
                   else
                     @response = {"errors" => "Request Declined! "+response.setlstat}
                   end



             rescue Exception => msg

                @response = {"errors" => msg}
             end

           #respstat is not 'A'
         else
           @response = {"errors" => "Request Declined! "+response.errors.join(",")}
           end
         #amount is not < '0'
         end

      rescue Exception => msg
          @response = {"errors" => msg}
      end


      p "w-------"
      p @response.inspect

     respond_to do |format|
           format.js  {}
     end

   end
 end


 def invite
  @kiosk = Kiosk.find(params[:id])

  if params.include?(:kiosk)
     KioskMailer.invite_email(params[:kiosk][:email],params[:kiosk][:subject], params[:kiosk][:mail_content]).deliver
     #mail(to: params[:kiosk][:email], subject: params[:kiosk][:subject], content: params[:kiosk][:mail_content])
     render 'invited'
  end
 end


 private

   def donation_params
     params.require(:kiosk).permit(donations_attributes:  [:title,:name, :email, :amount, :cardconnectref, :inv_num, :inv_desc] )
   end
end
