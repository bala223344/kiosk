class KioskMailer < ActionMailer::Base
  default from: 'admin@paynow.io'

  def online_email(charge)
    @charge = charge

    from = "#{charge['kiosk_title']} <admin@paynow.io>"
    mail(from: from, to: charge['email'], subject: 'Invoice - Payment Request')
  end


  def receipt_email(charge)
    @charge = charge
    from = "#{charge['kiosk_name']} <admin@paynow.io>"
    mail(from: from, to: charge['email'], subject: 'Payment Receipt')
  end


  def modal_receipt_email(donation)
    from = "#{donation.kiosk.title} <admin@paynow.io>"
    mail(from: from, to: donation['email'], subject: 'Payment Receipt - Duplicate')
  end

  def owner_email(charge)
    @charge = charge

    from = "#{charge['kiosk_name']} <admin@paynow.io>"
    mail(from: from, to: charge['email'], subject: 'Payment Received')
  end
end
