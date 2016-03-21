class IncomeDecorator < ApplicationDecorator
  decorates_association :account_histories

  delegate_all

  def name_with_price
    "Income #{display_amount}"
  end

  def display_amount
    h.nice_currency(model.amount)
  end

  def display_date
    h.nice_date(model.applied_at)
  end

  def tooltip_date
    h.nice_datetime(model.created_at)
  end
end
