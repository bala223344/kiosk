Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  devise_for :users, controllers: { registrations: 'users/registrations' }
  # , omniauth_callbacks: 'omniauth_callbacks'
  # devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }




  devise_scope :user do
    root to: 'users/registrations#edit'
  end



  resource :user, only: [:edit] do
    collection do
      patch 'update_password'
      patch 'update'
    end
  end

  # kiosk will be shown as donations while receiving donations..like http://paynow.io/donations/1001
  resources :kiosks
  
  namespace :dashboard do
    get 'vt', to: '/kiosks#vt'
    get 'reporting', to: '/kiosks#reporting'
    get 'donation_detail', to: '/kiosks#donation_detail'
    get 'bin', to: '/kiosks#bin'
    get 'online', to: '/kiosks#online'
    get 'contactless', to: '/contactless#show'
    post 'terminalsetup', to: '/contactless#terminalsetup'

    post 'online', to: '/kiosks#submit_online'
    post 'refund', to: '/kiosks#refund'
    post 'update_kiosk_profile', to: '/kiosks#update_profile'
    post 'update_kiosk_pref', to: '/kiosks#update_kiosk_pref'
    post 'sendreceipt', to: '/kiosks#sendreceipt'
    post 'slugupdate', to: '/kiosks#slugupdate'
    post 'ajx_charge_s1', to: '/pay#ajx_charge_s1'
    post 'ajx_charge_s2', to: '/pay#ajx_charge_s2'
    post 'update_notif_pref', to: '/users#update_notif_pref'
    
  end
  resources :activations
  resources :terms, only: [:index]


  #need to find a way for /secure/
  #resources :pay, path: :secure
  get 'secure/:kid', to: 'pay#show'
  resources :pay, path: '' do
   
  
   end
end
