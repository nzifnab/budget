class QuickFundDecorator < ApplicationDecorator
  delegate_all
  decorates_association :account_histories

  def name_with_type_and_price
    "#{name_with_type} #{display_amount}"
  end

  def name_with_type
    "Quick Fund #{display_fund_type.capitalize}"
  end

  def display_amount
    amt = fund_type.downcase == "withdraw" ? -model.amount : model.amount
    h.nice_currency(amt)
  end

  def display_fund_type
    fund_type.downcase == "withdraw" ? "withdrawal" : "deposit"
  end

  def amount_class
    h.amount_class(model.amount)
  end
end
