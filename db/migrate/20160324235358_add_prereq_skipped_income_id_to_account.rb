class AddPrereqSkippedIncomeIdToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :prereq_skipped_income_id, :integer
    add_column :accounts, :prereq_skipped_amount, :decimal, precision: 8, scale: 2
  end
end
