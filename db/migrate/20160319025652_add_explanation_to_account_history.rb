class AddExplanationToAccountHistory < ActiveRecord::Migration
  def change
    add_column :account_histories, :explanation, :text
  end
end
