module FormHelper
  def setup_user(user)
    user.kiosk ||= Kiosk.new
    user
  end


  def preview_link(instance)
      link_to kiosk_url(instance.kiosk),  kiosk_path(instance.kiosk),  :class => "" ,  :target => '_blank', :role => "button"
  end
end
