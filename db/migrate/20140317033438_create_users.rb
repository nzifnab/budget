class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.text :first_name
      t.text :last_name
      t.text :email
      t.string :password_digest
      t.decimal :undistributed_funds, precision: 10, scale: 2, default: 0

      t.timestamps
    end

    change_column :account_histories, :amount, :decimal, precision: 10, scale: 2
    change_column :accounts, :amount, :decimal, precision: 10, scale: 2
    change_column :quick_funds, :amount, :decimal, precision: 10, scale: 2
  end

  def down
    drop_table :users
  end
end
