class ActivationMailer < ActionMailer::Base
  default from: 'admin@paynow.io'

  def activation_email(activation)
    @content = '<br />Organization: ' + activation.title + '<br />Name: <b>' + activation.name + '</b><br />Phone: <b>' + activation.phone + '</b><br />Email: ' + activation.email + ''

    mail(to: 'scott@startgroup.org', subject: 'Merchant account activation - PayNow.io', body: @content, content_type: 'text/html').deliver
    # mail(to: "rameshkumar86@gmail.com", subject: 'Merchant account activation - PayNow.io',  body: @content,  content_type: "text/html")
  end
end
