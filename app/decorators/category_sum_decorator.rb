class CategorySumDecorator < ApplicationDecorator
  delegate_all

  def display_amount
    h.nice_currency(model.amount)
  end

  def amount_class
    h.amount_class(model.amount)
  end
end
