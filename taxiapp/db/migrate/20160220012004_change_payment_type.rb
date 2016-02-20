class ChangePaymentType < ActiveRecord::Migration
  def change
    change_column :orders, :payment_type, :string
  end
end
