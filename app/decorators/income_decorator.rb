class IncomeDecorator < ApplicationDecorator
  decorates_association :account_histories

  delegate_all

  def display_amount
    h.nice_currency(model.amount)
  end

  def display_date
    h.nice_date(model.created_at)
  end

  def tooltip_date
    h.nice_datetime(model.created_at)
  end
end
