ActiveAdmin.register User do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
 permit_params do
   permitted = [:merchid,:merchant_username,:merchant_password,:merchant_end_point]
#   permitted << :other if resource.something?
#   permitted
 end



 



 controller do

  def update_resource object, attributes
    attributes.each do |attr|
      if attr[:merchant_password].blank?
        attr.delete :merchant_password
      end
    end
  
    object.send :update_attributes, *attributes
  end




end  




end
