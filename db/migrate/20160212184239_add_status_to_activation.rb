class AddStatusToActivation < ActiveRecord::Migration
  def change
    add_column :activations, :status, :string
  end
end
