class KioskMailer < ActionMailer::Base
  default from: 'admin@paynow.io'

  def online_email(charge)
    @charge = charge

    from = "#{charge['kiosk_title']} <admin@paynow.io>"
    mail(from: from, to: charge['email'], subject: "Payment Request for #{charge['kiosk_title']}")
  end


  def receipt_email(charge)
    @charge = charge
    from = "#{charge['kiosk_name']} <admin@paynow.io>"
    mail(from: from, to: charge['email'], subject: "Payment Receipt #{charge['kiosk_name']}")
  end


  def modal_receipt_email(donation)
    from = "#{donation.kiosk.title} <admin@paynow.io>"
    mail(from: from, to: donation['email'], subject: "Duplicate Payment Receipt for #{donation.kiosk.title} ")
  end

  def owner_email(charge)
    @charge = charge

    from = "#{charge['kiosk_name']} <admin@paynow.io>"
    mail(from: from, to: charge['email'], subject: "Payment Received for #{charge['kiosk_name']}")
  end
end
