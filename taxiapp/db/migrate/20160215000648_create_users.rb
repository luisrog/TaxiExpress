class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :passwd
      t.string :first_name
      t.string :last_name
      t.string :role
      t.string :phone
      t.string :credit_card
      t.datetime :expiration_credit_card
      t.integer :cvv
      t.string :license
      t.string :soat
      t.string :brand
      t.string :modele
      t.string :plate

      t.timestamps null: false
    end
  end
end
