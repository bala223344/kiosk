class AddUserToChurches < ActiveRecord::Migration
  def change
    add_reference :churches, :user, index: true
  end
end
