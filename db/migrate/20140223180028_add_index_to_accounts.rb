class AddIndexToAccounts < ActiveRecord::Migration
  def change
    add_index :accounts, :negative_overflow_id
    add_index :accounts, :user_id
  end
end
