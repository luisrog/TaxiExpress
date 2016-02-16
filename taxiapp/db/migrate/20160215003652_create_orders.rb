class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :user_client, index: true
      t.integer :user_driver, index: true
      t.string :address_origin
      t.string :address_destination
      t.string :reference
      t.string :state
      t.integer :time_estimated
      t.integer :payment_type
      t.string :promotion_code
      t.decimal :amount
      t.datetime :start_time
      t.string :end_time

      t.timestamps null: false
    end
    add_foreign_key :orders, :users, column: :user_client
    add_foreign_key :orders, :users, column: :user_driver
  end
end
