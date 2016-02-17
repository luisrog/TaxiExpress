class CreateTests < ActiveRecord::Migration
  def change
    create_table :tests do |t|
      t.string :username
      t.string :passwd
      t.integer :state

      t.timestamps null: false
    end
  end
end
