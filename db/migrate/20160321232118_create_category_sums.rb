class CreateCategorySums < ActiveRecord::Migration
  def change
    create_table :category_sums do |t|
      t.text :name
      t.decimal :amount, precision: 8, scale: 2
      t.integer :user_id
      t.text :description

      t.timestamps
    end
  end
end
