ActiveAdmin.register User do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  permit_params do
    permitted = %i[merchid merchant_username merchant_password merchant_end_point cmodel]
    #   permitted << :other if resource.something?
    #   permitted
  end

  controller do
    def update_resource(object, attributes)
      attributes.each do |attr|
        attr.delete :merchant_password if attr[:merchant_password].blank?
      end

      object.send :update_attributes, *attributes
    end
   end

   form do |f|
      f.inputs "Edit User" do
        f.input :email
        f.input :merchid
        f.input :merchant_username
        f.input :merchant_password
        f.input :merchant_end_point
        f.input :cmodel,  :as => :select, :collection => [['Surcharge Model','surcharge'],['Gateway Model','gateway']] , :label => "Fee Recovery Model"

            
      end
      f.actions
    end
end
