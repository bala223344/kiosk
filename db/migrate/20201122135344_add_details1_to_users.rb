class AddDetails1ToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :phone, :string
    add_column :users, :fname, :string
    add_column :users, :lname, :string
    add_column :users, :tz, :string
    add_column :users, :password_changed_at, :datetime
    add_column :users, :notify_sms_hpp, :boolean
    add_column :users, :notify_email_hpp, :boolean
    add_column :users, :notify_email_daily, :boolean
    add_column :users, :notify_email_monthly, :boolean
  end
end
