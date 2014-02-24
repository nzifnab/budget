class CreateAccountHistories < ActiveRecord::Migration
  def change
    create_table :account_histories do |t|
      t.decimal :amount, precision: 8, scale: 2
      t.text :description
      t.integer :overflow_from_id
      t.integer :account_id
      t.integer :quick_fund_id
      t.integer :income_id

      t.timestamps
    end

    add_index :account_histories, :overflow_from_id
    add_index :account_histories, :account_id
    add_index :account_histories, :quick_fund_id
    add_index :account_histories, :income_id
  end
end
