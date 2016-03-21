class AddAppliedAtToAccount < ActiveRecord::Migration
  def change
    add_column :incomes, :applied_at, :datetime
  end
end
