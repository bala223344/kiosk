class RemoveDonationFormTitleFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :donation_form_title, :string
  end
end
