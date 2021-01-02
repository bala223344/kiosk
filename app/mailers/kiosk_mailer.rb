class KioskMailer < ActionMailer::Base
  default from: 'admin@paynow.io'

  def online_email(charge)
    @charge = charge
    mail(to: charge['email'], subject: 'Invoice - Payment Request')
  end


  def receipt_email(charge)
    @charge = charge
    mail(to: charge['email'], subject: 'Payment Receipt')
  end


  def modal_receipt_email(donation)
    @donation = donation
    mail(to: donation['email'], subject: 'Payment Receipt - Duplicate')
  end

  def owner_email(charge)
    @charge = charge
    mail(to: charge['email'], subject: 'Payment Received')
  end
end
