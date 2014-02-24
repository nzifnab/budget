class CreateQuickFunds < ActiveRecord::Migration
  def change
    create_table :quick_funds do |t|
      t.decimal :amount, precision: 8, scale: 2
      t.integer :account_id
      t.text :description
      t.string :fund_type

      t.timestamps
    end
    add_index :quick_funds, :account_id
  end
end
