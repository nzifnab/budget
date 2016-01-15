class CreateIncomes < ActiveRecord::Migration
  def change
    create_table :incomes do |t|
      t.decimal :amount
      t.integer :user_id
      t.text :description
      t.datetime :income_at

      t.timestamps
    end
  end
end
