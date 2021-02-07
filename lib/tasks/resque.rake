
task mid_night: [:environment] do
  #get whatever kiosks got tx in the last 24 hours
  donations = Donation.where(created_at: (Time.now - 24.hours)..Time.now)
  kiosks = Array.new
  sum_today = Hash.new
  emp_tips_uniq = Hash.new
  tip_today = 0
  sale_today = 0
  fee_today = 0

  if donations.any?
    donations.each do |rec|
      kiosks.push(rec.kiosk_id)
      if sum_today[rec.kiosk_id]
        sum_today[rec.kiosk_id] += rec.amount.to_f
      else
        sum_today[rec.kiosk_id] = rec.amount.to_f
      end

      if rec.tip_amt

        if emp_tips_uniq[rec.emp]
          emp_tips_uniq[rec.emp] += rec.tip_amt.to_f
        else
          emp_tips_uniq[rec.emp] = rec.tip_amt.to_f
        end

        tip_today += rec.tip_amt.to_f
        sale_today += rec.amount.to_f
        fee_today += rec.gateway_fee.to_f


      end


    end


    kiosks = kiosks.uniq

    month_total = 0
    month_tip = 0
    month_fee = 0
    if kiosks.any?
      kiosks.each do |rec|
        kiosk = Kiosk.find(rec)
        donations = Donation.where(created_at: (Time.now - 1.month)..Time.now).where(kiosk_id: rec)
        donations.each do |d|
          month_total += d.amount.to_f
          month_tip += d.tip_amt.to_f
          month_fee += d.gateway_fee.to_f
        end
        charge =  {"fname" => kiosk.user.fname, "kiosk_name" => kiosk.title, "email" => kiosk.user.email, "date"=> Time.now.strftime("%^b %d, %Y"), "month" =>  Time.now.strftime("%^b"), "day" => Time.now.strftime("%d").to_i, "sale_today" => sale_today, "month_total" => month_total, "month_tip" => month_tip, "tip_today" => tip_today, "fee_today" => fee_today, "month_fee" => month_fee, "emp_tips_uniq" => emp_tips_uniq}
        KioskMailer.daily_report_email(charge).deliver

      end
    end
  end


  
end

# although this is weekly scheduler setup is for everyday..bcz heroku doesn't have weekly..
# cron runs at UTC 12.00 PM which is 8 AM NY Time --

