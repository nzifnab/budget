class AddAttributesToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :prerequisite_account_id, :integer
    add_column :accounts, :cap, :decimal
    add_column :accounts, :add_per_month, :decimal, default: 0
    add_column :accounts, :add_per_month_type, :text, default: '$'
    add_column :accounts, :monthly_cap, :decimal
    add_column :accounts, :overflow_into_id, :integer
  end
end
