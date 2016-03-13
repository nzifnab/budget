class Income < ActiveRecord::Base
  belongs_to :user, inverse_of: :incomes
  has_many :account_histories, inverse_of: :income
end
