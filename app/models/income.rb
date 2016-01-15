class Income < ActiveRecord::Base
  belongs_to :user, inverse_of: :incomes
end
