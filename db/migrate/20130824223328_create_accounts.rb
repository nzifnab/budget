class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.text :name
      t.text :description
      t.integer :priority
      t.boolean :enabled
      t.decimal :amount, :precision => 8, :scale => 2
      t.integer :negative_overflow_id
      t.integer :user_id

      t.timestamps
    end
  end
end
