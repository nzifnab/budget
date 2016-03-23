class CreateCategorySums < ActiveRecord::Migration
  def change
    create_table :category_sums do |t|
      t.text :name
      t.decimal :amount, precision: 8, scale: 2, default: 0, nil: false
      t.integer :user_id
      t.text :description

      t.timestamps
    end

    add_column :accounts, :category_sum_id, :integer

    add_index :accounts, :category_sum_id
    add_index :category_sums, :user_id
    add_index :incomes, :applied_at
  end
end
