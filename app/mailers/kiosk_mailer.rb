class KioskMailer < ActionMailer::Base
  default from: 'admin@paynow.io'

  def receipt_email(charge)
    @charge = charge
    mail(to: charge['email'], subject: 'Payment receipt - PayNow.io')
  end

  def owner_email(charge)
    @charge = charge
    mail(to: charge['email'], subject: 'Payment Received - PayNow.io')
  end
end
