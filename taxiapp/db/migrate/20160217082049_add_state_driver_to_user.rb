class AddStateDriverToUser < ActiveRecord::Migration
  def change
    add_column :users, :state_driver, :string
  end
end
