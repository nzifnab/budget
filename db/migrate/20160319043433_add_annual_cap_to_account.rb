class AddAnnualCapToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :annual_cap, :decimal, precision: 8, scale: 2
  end
end
