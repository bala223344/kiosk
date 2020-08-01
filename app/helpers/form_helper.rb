module FormHelper
  def setup_user(user)

    user.kiosk ||= Kiosk.new
    if user.kiosk.amount && user.kiosk.amount > 0
      @share_url = URI.escape("https://paynow.io/secure/#{user.kiosk.id}?amount=#{user.kiosk.amount}&inv_num=#{user.kiosk.inv_num}&inv_desc=#{user.kiosk.inv_desc}")
      require 'rqrcode'
      qrcode = RQRCode::QRCode.new(@share_url,  level: :l)
      @qr = qrcode.as_svg(
        offset: 0,
        color: '000',
        shape_rendering: 'crispEdges',
        module_size: 6,
        standalone: true
      )
  
    end


    user
   
  end

  def preview_link(instance)
    link_to kiosk_url(instance.kiosk), kiosk_path(instance.kiosk), class: '', target: '_blank', role: 'button'
  end
end
